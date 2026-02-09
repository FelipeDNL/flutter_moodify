import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_test/data/const/ui_constants.dart';
import 'package:flutter_application_test/data/services/mood_music_service.dart';
import 'package:flutter_application_test/ui/core/home/mood_form.dart';
import 'package:flutter_application_test/ui/core/home/music_card.dart';
import 'package:flutter_application_test/ui/core/home/weekly_mood_chart.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Páginas para cada item do bottom navigation
  final List<Widget> _pages = [
    const HomePage(),
    const StatsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.onSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Página Inicial
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _moodMusicService = MoodMusicService();
  List<Map<String, dynamic>> _musicList = [];
  bool _isLoading = true;
  bool _hasMusicToday = false;

  @override
  void initState() {
    super.initState();
    _loadMusicList();
  }

  Future<void> _loadMusicList() async {
    try {
      final list = await _moodMusicService.getCurrentWeekMusicList();
      final hasToday = await _moodMusicService.hasMusicToday();
      setState(() {
        _musicList = list;
        _hasMusicToday = hasToday;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como você está se sentindo?',
              style: TextStyle(
                color: AppTheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe seu humor semanal',
              style: TextStyle(
                color: AppTheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            const WeeklyMoodChart(),
            const SizedBox(height: 24),

            // Músicas da Semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Músicas da Semana',
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_musicList.isNotEmpty)
                  Text(
                    '${_musicList.length} música${_musicList.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppTheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de Músicas
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _musicList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_note_outlined,
                                size: 64,
                                color: AppTheme.onSurface.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma música esta semana',
                                style: TextStyle(
                                  color: AppTheme.onSurface.withValues(alpha: 0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Vá para Estatísticas para adicionar!',
                                style: TextStyle(
                                  color: AppTheme.onSurface.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadMusicList,
                          child: ListView.builder(
                            itemCount: _musicList.length,
                            itemBuilder: (context, index) {
                              return MusicCard(musicData: _musicList[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Página de Estatísticas - Agora é um botão que abre o drawer
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _moodMusicService = MoodMusicService();
  bool _hasMusicToday = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkMusicToday();
  }

  Future<void> _checkMusicToday() async {
    try {
      final hasToday = await _moodMusicService.hasMusicToday();
      setState(() {
        _hasMusicToday = hasToday;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleAddMusic() {
    if (_hasMusicToday) {
      // Mostrar modal de aviso
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BorderRadiusConstants.borderRadius),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Música já registrada',
                style: TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Você já registrou uma música hoje! Volte amanhã para adicionar outra e continuar acompanhando seu humor.',
            style: TextStyle(
              color: AppTheme.onSurface.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Entendi',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Abrir formulário
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const MoodFormBottomSheet(),
      ).then((_) {
        // Recarregar o status após fechar o formulário
        _checkMusicToday();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_music_outlined,
                    size: 80,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Registre sua música e humor',
                    style: TextStyle(
                      color: AppTheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasMusicToday
                        ? 'Você já registrou hoje!'
                        : 'Toque no botão abaixo para começar',
                    style: TextStyle(
                      color: AppTheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: ElevatedButton.icon(
                      onPressed: _handleAddMusic,
                      icon: Icon(_hasMusicToday ? Icons.check_circle : Icons.add),
                      label: Text(_hasMusicToday ? 'Música Registrada' : 'Adicionar Música'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasMusicToday
                            ? AppTheme.onSurface.withValues(alpha: 0.3)
                            : AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            BorderRadiusConstants.borderRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Página de Perfil
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perfil',
              style: TextStyle(
                color: AppTheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}