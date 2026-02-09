import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/services/mood_music_service.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';

class WeeklyMoodChart extends StatefulWidget {
  const WeeklyMoodChart({super.key});

  @override
  State<WeeklyMoodChart> createState() => _WeeklyMoodChartState();
}

class _WeeklyMoodChartState extends State<WeeklyMoodChart> {
  final _moodMusicService = MoodMusicService();
  Map<int, List<Map<String, dynamic>>>? _weeklyData;
  bool _isLoading = true;
  String? _error;

  // Lista de emojis para representar os humores (igual ao mood_form.dart)
  final List<String> _moodEmojis = [
    '😢', // 0 - Triste
    '😐', // 1 - Neutro
    '🙂', // 2 - Bem
    '😊', // 3 - Feliz
    '🤩', // 4 - Muito Feliz
  ];

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    try {
      final data = await _moodMusicService.getWeeklyMoodDataWithCovers();
      setState(() {
        _weeklyData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Calcula a média de humor para um dia
  double _getAverageMood(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return -1;
    final moods = entries.map((e) => e['mood'] as int).toList();
    return moods.reduce((a, b) => a + b) / moods.length;
  }

  // Retorna a capa de álbum mais recente para um dia (última música registrada)
  String? _getAlbumCoverForDay(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return null;
    // Retorna a última capa registrada do dia
    return entries.last['albumCover'] as String?;
  }

  // Retorna os nomes dos dias da semana
  String _getDayLabel(int index) {
    // 0 = Segunda, 1 = Terça, ..., 6 = Domingo
    final weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return weekdays[index];
  }

  // Cria os overlays de album covers para cada ponto de dados
  List<Widget> _buildAlbumCoverOverlays(double chartWidth) {
    if (_weeklyData == null) return [];

    final List<Widget> covers = [];
    const double chartHeight = 160;
    const double leftReservedSize = 40;
    const double bottomReservedSize = 30;
    const double topPadding = 10;
    const double rightPadding = 0;

    // Área efetiva do gráfico
    const double effectiveHeight = chartHeight - bottomReservedSize - topPadding;
    final double effectiveWidth = chartWidth - leftReservedSize - rightPadding;

    for (var entry in _weeklyData!.entries) {
      if (entry.value.isEmpty) continue;

      final dayIndex = entry.key;
      final avgMood = _getAverageMood(entry.value);
      final albumCoverBase64 = _getAlbumCoverForDay(entry.value);

      if (albumCoverBase64 == null) continue;

      // Calcula a posição X
      final normalizedX = dayIndex / 6.0; // 0.0 a 1.0
      final xPosition = leftReservedSize + (effectiveWidth * normalizedX);

      // Calcula a posição Y (invertido porque Y cresce para baixo)
      // Mood 4 = topo, Mood 0 = fundo
      final normalizedY = avgMood / 4.0; // 0.0 a 1.0
      final yPosition = topPadding + effectiveHeight * (1 - normalizedY);

      covers.add(
        Positioned(
          left: xPosition - 16, // Centralizar a capa (32/2 = 16)
          top: yPosition - 16, // Centralizar a capa (32/2 = 16)
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.memory(
                _moodMusicService.decodeBase64ToImage(albumCoverBase64),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    child: Icon(
                      Icons.music_note,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    return covers;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: TextStyle(
                color: AppTheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_weeklyData == null || _weeklyData!.values.every((list) => list.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 64,
              color: AppTheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro esta semana',
              style: TextStyle(
                color: AppTheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comece registrando suas músicas!',
              style: TextStyle(
                color: AppTheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: AppTheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Humor da Semana',
                style: TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.onSurface.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        // Só mostrar emoji se for exatamente um inteiro entre 0 e 4
                        if (value != value.roundToDouble() || value < 0 || value > 4) {
                          return const SizedBox.shrink();
                        }
                        final moodIndex = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            _moodEmojis[moodIndex],
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < 0 || value.toInt() > 6) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getDayLabel(value.toInt()),
                            style: TextStyle(
                              color: AppTheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.onSurface.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: AppTheme.onSurface.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: -0.2,
                maxY: 4.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: _weeklyData!.entries
                        .where((entry) => entry.value.isNotEmpty)
                        .map((entry) {
                      final avgMood = _getAverageMood(entry.value);
                      return FlSpot(entry.key.toDouble(), avgMood);
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppTheme.onSurface.withValues(alpha: 0.9),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final dayIndex = spot.x.toInt();
                        final entries = _weeklyData![dayIndex]!;
                        return LineTooltipItem(
                          '${_getDayLabel(dayIndex)}\n',
                          TextStyle(
                            color: AppTheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Média: ${spot.y.toStringAsFixed(1)}\n',
                              style: TextStyle(
                                color: AppTheme.surface.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: '${entries.length} música${entries.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: AppTheme.surface.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
                    // Overlay de album covers nos pontos de dados
                    ..._buildAlbumCoverOverlays(constraints.maxWidth),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Humor médio do dia',
                style: TextStyle(
                  color: AppTheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
