import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/const/ui_constants.dart';
import 'package:flutter_application_test/data/services/mood_music_service.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';
import 'package:flutter_application_test/ui/core/ui/widgets/custom_elevated_buttom.dart';
import 'package:flutter_application_test/ui/widgets/custom_text_input.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MoodFormBottomSheet extends StatefulWidget {
  const MoodFormBottomSheet({super.key});

  @override
  State<MoodFormBottomSheet> createState() => _MoodFormBottomSheetState();
}

class _MoodFormBottomSheetState extends State<MoodFormBottomSheet> {
  final _bandController = TextEditingController();
  final _albumController = TextEditingController();
  final _musicNameController = TextEditingController();
  File? _albumCover;
  final ImagePicker _picker = ImagePicker();
  int? _selectedMood; // 0 a 4

  final _moodMusicService = MoodMusicService();
  bool _isSubmitting = false;

  // Lista de emojis para representar os humores
  final List<String> _moodEmojis = [
    '😢', // 0 - Triste
    '😐', // 1 - Neutro
    '🙂', // 2 - Bem
    '😊', // 3 - Feliz
    '🤩', // 4 - Muito Feliz
  ];

  final List<String> _moodLabels = [
    'Triste',
    'Neutro',
    'Bem',
    'Feliz',
    'Muito Feliz',
  ];

  @override
  void dispose() {
    _bandController.dispose();
    _albumController.dispose();
    _musicNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _albumCover = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    final band = _bandController.text.trim();
    final album = _albumController.text.trim();
    final musicName = _musicNameController.text.trim();

    if (band.isEmpty || album.isEmpty || musicName.isEmpty || _albumCover == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e adicione uma capa.')),
      );
      return;
    }

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione seu humor.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Salvar música com humor no Firebase
      await _moodMusicService.saveMoodMusic(
        band: band,
        album: album,
        musicName: musicName,
        albumCover: _albumCover!,
        mood: _selectedMood!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Música "$musicName" registrada com humor: ${_moodEmojis[_selectedMood!]}'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BorderRadiusConstants.borderRadius),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Registrar Música e Humor',
                        style: TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Compartilhe a música que está ouvindo e como se sente.',
                        style: TextStyle(
                          color: AppTheme.onSurface.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Banda
                      CustomTextInput(
                        label: 'Banda',
                        controller: _bandController,
                      ),
                      const SizedBox(height: 16),

                      // Álbum
                      CustomTextInput(
                        label: 'Álbum',
                        controller: _albumController,
                      ),
                      const SizedBox(height: 16),

                      // Nome da Música
                      CustomTextInput(
                        label: 'Nome da Música',
                        controller: _musicNameController,
                      ),
                      const SizedBox(height: 24),

                      // Capa do Álbum
                      Text(
                        'Capa do Álbum',
                        style: TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      GestureDetector(
                        onTap: _isSubmitting ? null : _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppTheme.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadiusConstants.defaultBorderRadius,
                            border: Border.all(
                              color: AppTheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                          child: _albumCover != null
                              ? ClipRRect(
                                  borderRadius: BorderRadiusConstants.defaultBorderRadius,
                                  child: Image.file(
                                    _albumCover!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 48,
                                      color: AppTheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Toque para adicionar capa',
                                      style: TextStyle(
                                        color: AppTheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Humor - Seletor de Emojis
                      Text(
                        'Qual o seu humor hoje?',
                        style: TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Linha única de 5 emojis
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return _buildMoodButton(index);
                        }),
                      ),
                      
                      const SizedBox(height: 32),

                      // Botão de envio
                      CustomFilledButton(
                        label: _isSubmitting ? 'Registrando...' : 'Registrar',
                        onPressed: _isSubmitting ? () {} : _submitForm,
                        backgroundColor: AppTheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodButton(int moodValue) {
    final isSelected = _selectedMood == moodValue;

    return GestureDetector(
      onTap: _isSubmitting ? null : () {
        setState(() {
          _selectedMood = moodValue;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.3)
                  : AppTheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.onSurface.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                _moodEmojis[moodValue],
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _moodLabels[moodValue],
            style: TextStyle(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.onSurface.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}