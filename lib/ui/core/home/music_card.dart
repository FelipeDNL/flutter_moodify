import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/const/ui_constants.dart';
import 'package:flutter_application_test/data/services/mood_music_service.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';
import 'package:intl/intl.dart';

class MusicCard extends StatelessWidget {
  final Map<String, dynamic> musicData;
  final MoodMusicService _moodMusicService = MoodMusicService();

  MusicCard({super.key, required this.musicData});

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
                  musicName,
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
        ],
      ),
    );
  }
}
