import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/datasources/quran_audio_service.dart';

class QuranAudioPlayer extends StatefulWidget {

  const QuranAudioPlayer({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });
  final int surahNumber;
  final String surahName;

  @override
  State<QuranAudioPlayer> createState() => _QuranAudioPlayerState();
}

class _QuranAudioPlayerState extends State<QuranAudioPlayer> {
  final _audioService = QuranAudioService();

  @override
  void initState() {
    super.initState();
    _audioService.init();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _audioService.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        // Don't show if stopped or initial
        if (processingState == ProcessingState.idle) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(16),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Info & Controls
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.goldenHour.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.audiotrack_rounded,
                        color: AppColors.goldenHour,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.surahName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Mishary Rashid Alafasy',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Controls
                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Previous Ayah
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded,
                                color: Colors.white70, size: 24),
                            onPressed: () => _audioService.seekToPrevious(),
                          ),

                          // Play/Pause
                          IconButton(
                            icon: Icon(
                              playing == true
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              if (playing == true) {
                                _audioService.pause();
                              } else {
                                _audioService.resume();
                              }
                            },
                          ),

                          // Next Ayah
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded,
                                color: Colors.white70, size: 24),
                            onPressed: () => _audioService.seekToNext(),
                          ),

                          // Stop
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white38, size: 20),
                            onPressed: () => _audioService.stop(),
                          ),
                        ],
                      ),
                  ],
                ),

                // Bottom Row: Progress System
                StreamBuilder<Duration>(
                  stream: _audioService.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: _audioService.durationStream,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14),
                                activeTrackColor: AppColors.goldenHour,
                                inactiveTrackColor: Colors.white12,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: position.inSeconds
                                    .toDouble()
                                    .clamp(0, duration.inSeconds.toDouble()),
                                max: duration.inSeconds.toDouble() > 0
                                    ? duration.inSeconds.toDouble()
                                    : 1,
                                onChanged: (value) {
                                  _audioService
                                      .seek(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 10),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
