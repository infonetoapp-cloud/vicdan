import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../shared/widgets/glass_card.dart';
import '../../../../core/theme/app_colors.dart';

class QuranRadioScreen extends StatefulWidget {
  const QuranRadioScreen({super.key});

  @override
  State<QuranRadioScreen> createState() => _QuranRadioScreenState();
}

class _QuranRadioScreenState extends State<QuranRadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initRadio();
  }

  Future<void> _initRadio() async {
    // Check internet first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'İnternet bağlantısı yok.\nRadyo için internet gereklidir.';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // 24/7 Quran Radio (e.g. Mishary Alafasy)
      // URL: http://live.mp3quran.net:9976
      await _player.setUrl('http://live.mp3quran.net:9976');
      _player.play();

      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Radyo bağlanamadı.\nLütfen daha sonra tekrar deneyin.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.textDark),
                  ),
                  const Expanded(
                    child: Text(
                      "Canlı Kur'an Radyosu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance back button
                ],
              ),
            ),

            const Spacer(),

            // Main Visualizer & Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // Visualizer Placeholder (or Icon)
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            color: AppColors.textDark.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold
                                .withOpacity(_isPlaying ? 0.3 : 0.0),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            // Base shadow
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]),
                    child: Icon(
                      Icons.radio,
                      size: 80,
                      color: _isPlaying
                          ? AppColors.accentGold
                          : AppColors.textDisabled,
                    ),
                  ),

                  const SizedBox(height: 48),

                  const Text(
                    'Mishary Rashid Alafasy',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '7/24 Kesintisiz Yayın',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Controls
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(32),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: Colors.amber, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                              _isLoading = true;
                            });
                            _initRadio();
                          },
                          child: const Text('Tekrar Dene'),
                        )
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play/Pause Button
                    GestureDetector(
                      onTap: () {
                        if (_isPlaying) {
                          _player.pause();
                        } else {
                          _player.play();
                        }
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ]),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(
                                    color: AppColors.goldenHour),
                              )
                            : Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 40,
                                color: AppColors.goldenHour,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
