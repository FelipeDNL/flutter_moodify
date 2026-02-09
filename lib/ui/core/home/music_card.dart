import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/const/ui_constants.dart';
import 'package:flutter_application_test/data/services/mood_music_service.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';
import 'package:intl/intl.dart';

class MusicCard extends StatelessWidget {
  final Map<String, dynamic> musicData;
  final VoidCallback? onDelete;
  final MoodMusicService _moodMusicService = MoodMusicService();

  MusicCard({super.key, required this.musicData, this.onDelete});

  // Mapeamento de mood para emoji
  static const Map<int, String> _moodEmojis = {
    0: '😢', // Triste
    1: '😐', // Neutro
    2: '🙂', // Bem
    3: '😊', // Feliz
    4: '🤩', // Muito Feliz
  };

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final musicDate = DateTime(date.year, date.month, date.day);

    if (musicDate == today) {
      return 'Hoje';
    } else if (musicDate == yesterday) {
      return 'Ontem';
    } else {
      // Retorna o nome do dia da semana
      final weekdays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
      final weekdayIndex = date.weekday - 1; // 1 = Monday, 7 = Sunday
      return weekdays[weekdayIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    final band = musicData['band'] as String? ?? '';
    final musicName = musicData['musicName'] as String? ?? '';
    final albumCoverBase64 = musicData['albumCoverBase64'] as String?;
    final createdAt = musicData['createdAt'] as DateTime?;
    final mood = musicData['mood'] as int?;
    final id = musicData['id'] as String?;
    final moodEmoji = mood != null ? _moodEmojis[mood] ?? '' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadiusConstants.defaultBorderRadius,
        border: Border.all(
          color: AppTheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Album Cover
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.onSurface.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: albumCoverBase64 != null
                  ? Image.memory(
                      _moodMusicService.decodeBase64ToImage(albumCoverBase64),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.music_note,
                          size: 30,
                          color: AppTheme.onSurface.withValues(alpha: 0.3),
                        );
                      },
                    )
                  : Icon(
                      Icons.music_note,
                      size: 30,
                      color: AppTheme.onSurface.withValues(alpha: 0.3),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Music Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$moodEmoji $musicName',
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  band,
                  style: TextStyle(
                    color: AppTheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(
                    color: AppTheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppTheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: () async {
              if (id == null) return;

              // Show confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Excluir música'),
                  content: const Text('Deseja realmente excluir esta música?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  await _moodMusicService.deleteMoodMusic(id);
                  if (onDelete != null) {
                    onDelete!();
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Música excluída com sucesso'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
