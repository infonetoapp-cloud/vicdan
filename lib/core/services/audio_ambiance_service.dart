import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../features/home/presentation/widgets/mood_sanctuary_sheet.dart';

class AudioAmbianceService {
  static final AudioAmbianceService _instance =
      AudioAmbianceService._internal();
  factory AudioAmbianceService() => _instance;
  AudioAmbianceService._internal();

  AudioPlayer? _primaryPlayer;
  AudioPlayer? _secondaryPlayer; // For layering (e.g., Rain + Ney)

  /// Plays the ambiance matching the mood.
  /// Handles file missing errors gracefully.
  Future<void> playForMood(MoodType mood) async {
    // If already playing the same mood's sound, maybe do nothing?
    // For now, let's stop and restart to ensure sync.
    await stop();

    try {
      _primaryPlayer = AudioPlayer();
      _secondaryPlayer = AudioPlayer();

      switch (mood) {
        case MoodType.daraldim:
          // Inshirah Therapy: Deep Ney + Light Rain
          await _setupPlayer(_primaryPlayer!, 'assets/audio/ambience_ney.mp3',
              volume: 0.6);
          await _setupPlayer(
              _secondaryPlayer!, 'assets/audio/ambience_rain.mp3',
              volume: 0.3);
          break;

        case MoodType.huzur:
          // Peace: Water stream + Birds
          await _setupPlayer(_primaryPlayer!, 'assets/audio/ambience_water.mp3',
              volume: 0.5);
          break;

        case MoodType.sukur:
          // Gratitude: Soft instrumental (or silence)
          // Let's assume silence or a very soft wind
          await _setupPlayer(_primaryPlayer!, 'assets/audio/ambience_wind.mp3',
              volume: 0.2);
          break;

        case MoodType.karisik:
          // Mixed: Mystery wind
          await _setupPlayer(_primaryPlayer!, 'assets/audio/ambience_wind.mp3',
              volume: 0.4);
          break;
      }
    } catch (e) {
      debugPrint("AudioAmbianceService Error: $e");
      // Prevent crash if assets are missing
      await stop();
    }
  }

  Future<void> _setupPlayer(AudioPlayer player, String assetPath,
      {double volume = 0.5}) async {
    try {
      await player.setAsset(assetPath);
      await player.setLoopMode(LoopMode.one); // Loop indefinitely
      await player.setVolume(volume);
      player.play(); // Fire and forget
    } catch (e) {
      debugPrint("Could not load asset: $assetPath. Error: $e");
      // If primary asset fails, we might want to know, but for now just log it.
    }
  }

  Future<void> stop() async {
    // Fade out effect could be added here
    try {
      await _primaryPlayer?.stop();
      await _secondaryPlayer?.stop();
    } catch (e) {
      // Ignore stop errors
    } finally {
      _primaryPlayer?.dispose();
      _secondaryPlayer?.dispose();
      _primaryPlayer = null;
      _secondaryPlayer = null;
    }
  }

  void dispose() {
    stop();
  }
}
