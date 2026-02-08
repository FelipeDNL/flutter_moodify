import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MoodMusicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Salva uma música com humor no Firestore
  /// Retorna o ID do documento criado
  Future<String> saveMoodMusic({
    required String band,
    required String album,
    required String musicName,
    required File albumCover,
    required int mood,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Converter imagem para Base64
      final coverBase64 = await _convertImageToBase64(albumCover);

      // Criar documento no Firestore
      final docRef = await _firestore.collection('mood_music').add({
        'userId': user.uid,
        'band': band,
        'album': album,
        'musicName': musicName,
        'albumCoverBase64': coverBase64,
        'mood': mood,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Música salva com sucesso: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao salvar música: $e');
      rethrow;
    }
  }

  /// Converte uma imagem File para string Base64
  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      debugPrint('Imagem convertida para Base64 (${base64String.length} caracteres)');
      return base64String;
    } catch (e) {
      debugPrint('Erro ao converter imagem para Base64: $e');
      rethrow;
    }
  }

  /// Obtém todas as músicas com humor do usuário atual
  Stream<QuerySnapshot> getUserMoodMusic() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    return _firestore
        .collection('mood_music')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Obtém uma música específica por ID
  Future<DocumentSnapshot> getMoodMusicById(String id) async {
    return await _firestore.collection('mood_music').doc(id).get();
  }

  /// Atualiza uma música existente
  Future<void> updateMoodMusic({
    required String id,
    String? band,
    String? album,
    String? musicName,
    File? albumCover,
    int? mood,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (band != null) updates['band'] = band;
      if (album != null) updates['album'] = album;
      if (musicName != null) updates['musicName'] = musicName;
      if (mood != null) updates['mood'] = mood;

      // Se houver nova imagem, converte para Base64
      if (albumCover != null) {
        final coverBase64 = await _convertImageToBase64(albumCover);
        updates['albumCoverBase64'] = coverBase64;
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('mood_music').doc(id).update(updates);
      debugPrint('Música atualizada com sucesso');
    } catch (e) {
      debugPrint('Erro ao atualizar música: $e');
      rethrow;
    }
  }

  /// Deleta uma música
  Future<void> deleteMoodMusic(String id) async {
    try {
      await _firestore.collection('mood_music').doc(id).delete();
      debugPrint('Música deletada com sucesso');
    } catch (e) {
      debugPrint('Erro ao deletar música: $e');
      rethrow;
    }
  }

  /// Obtém estatísticas de humor do usuário
  Future<Map<int, int>> getMoodStatistics() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final snapshot = await _firestore
        .collection('mood_music')
        .where('userId', isEqualTo: user.uid)
        .get();

    final Map<int, int> statistics = {};
    
    for (var doc in snapshot.docs) {
      final mood = doc.data()['mood'] as int;
      statistics[mood] = (statistics[mood] ?? 0) + 1;
    }

    return statistics;
  }

  /// Método auxiliar para decodificar Base64 de volta para bytes
  /// Use isso quando precisar exibir a imagem
  Uint8List decodeBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }
}