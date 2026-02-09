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

  /// Obtém os dados de humor da última semana (7 dias)
  /// Retorna um Map onde a chave é o dia da semana (0-6, onde 0 é hoje)
  /// e o valor é uma lista de humores registrados naquele dia
  Future<Map<int, List<int>>> getWeeklyMoodData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Calcula a data de 7 dias atrás (início da semana)
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    // Busca todos os registros da última semana
    final snapshot = await _firestore
        .collection('mood_music')
        .where('userId', isEqualTo: user.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .orderBy('createdAt', descending: false)
        .get();

    // Organiza os dados por dia
    final Map<int, List<int>> weeklyData = {
      0: [], // 6 dias atrás
      1: [], // 5 dias atrás
      2: [], // 4 dias atrás
      3: [], // 3 dias atrás
      4: [], // 2 dias atrás
      5: [], // 1 dia atrás
      6: [], // hoje
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final mood = data['mood'] as int;

      if (createdAt != null) {
        // Calcula quantos dias atrás foi esse registro
        final daysAgo = now.difference(DateTime(createdAt.year, createdAt.month, createdAt.day)).inDays;

        // Se está dentro da semana (0-6 dias atrás)
        if (daysAgo >= 0 && daysAgo <= 6) {
          final dayIndex = 6 - daysAgo; // Inverte para que 0 seja 6 dias atrás e 6 seja hoje
          weeklyData[dayIndex]?.add(mood);
        }
      }
    }

    return weeklyData;
  }

  /// Obtém os dados detalhados de humor da semana vigente (Segunda a Domingo) incluindo capas
  /// Retorna um Map onde a chave é o dia da semana (0-6, onde 0 é Segunda e 6 é Domingo)
  /// e o valor é uma lista de Maps com mood e albumCover
  Future<Map<int, List<Map<String, dynamic>>>> getWeeklyMoodDataWithCovers() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final now = DateTime.now();

    // Calcula a segunda-feira da semana atual
    // DateTime.weekday retorna 1 para segunda, 2 para terça, etc., até 7 para domingo
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final daysFromMonday = currentWeekday - 1; // 0 se hoje é segunda, 6 se hoje é domingo
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));

    // Calcula o domingo (6 dias após a segunda)
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // Busca todos os registros da semana vigente
    final snapshot = await _firestore
        .collection('mood_music')
        .where('userId', isEqualTo: user.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monday))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(sunday))
        .orderBy('createdAt', descending: false)
        .get();

    // Organiza os dados por dia da semana
    final Map<int, List<Map<String, dynamic>>> weeklyData = {
      0: [], // Segunda-feira
      1: [], // Terça-feira
      2: [], // Quarta-feira
      3: [], // Quinta-feira
      4: [], // Sexta-feira
      5: [], // Sábado
      6: [], // Domingo
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final mood = data['mood'] as int;
      final albumCoverBase64 = data['albumCoverBase64'] as String?;

      if (createdAt != null) {
        // Calcula o índice do dia da semana (0 = Segunda, 6 = Domingo)
        final daysSinceMonday = createdAt.difference(monday).inDays;

        if (daysSinceMonday >= 0 && daysSinceMonday <= 6) {
          weeklyData[daysSinceMonday]?.add({
            'mood': mood,
            'albumCover': albumCoverBase64,
          });
        }
      }
    }

    return weeklyData;
  }

  /// Verifica se já existe uma música registrada hoje
  /// Retorna true se já existe, false caso contrário
  Future<bool> hasMusicToday() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1, seconds: -1));

    final snapshot = await _firestore
        .collection('mood_music')
        .where('userId', isEqualTo: user.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Obtém todas as músicas da semana vigente (Segunda a Domingo)
  /// Retorna uma lista de Maps com todos os detalhes das músicas
  Future<List<Map<String, dynamic>>> getCurrentWeekMusicList() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final now = DateTime.now();

    // Calcula a segunda-feira da semana atual
    final currentWeekday = now.weekday;
    final daysFromMonday = currentWeekday - 1;
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));

    // Calcula o domingo (6 dias após a segunda)
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // Busca todos os registros da semana vigente
    final snapshot = await _firestore
        .collection('mood_music')
        .where('userId', isEqualTo: user.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monday))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(sunday))
        .orderBy('createdAt', descending: true)
        .get();

    // Converte para lista de Maps
    final List<Map<String, dynamic>> musicList = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      musicList.add({
        'id': doc.id,
        'band': data['band'] as String?,
        'album': data['album'] as String?,
        'musicName': data['musicName'] as String?,
        'albumCoverBase64': data['albumCoverBase64'] as String?,
        'mood': data['mood'] as int?,
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
      });
    }

    return musicList;
  }
}