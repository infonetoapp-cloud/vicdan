import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class QuranAudioService {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;
  QuranAudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<int?> get currentAyahIndexStream => _player.currentIndexStream;

  bool get isPlaying => _player.playing;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  /// Plays the entire surah verse by verse (Gapless Playback)
  /// [initialIndex] is 0-based. If provided, starts playback from this ayah.
  Future<void> playSurah(int surahNumber, int totalAyahs,
      {int initialIndex = 0}) async {
    // 1. Check Internet Connection
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception(
          "İnternet bağlantısı yok.\nSes dosyaları çevrimiçi kaynaklardan oynatılmaktadır.");
    }

    try {
      final List<AudioSource> ayahs = [];
      final surahPrefix = surahNumber.toString().padLeft(3, '0');

      for (int i = 1; i <= totalAyahs; i++) {
        final ayahSuffix = i.toString().padLeft(3, '0');
        final url =
            'https://everyayah.com/data/Alafasy_128kbps/$surahPrefix$ayahSuffix.mp3';
        ayahs.add(AudioSource.uri(
          Uri.parse(url),
          tag: {'surah': surahNumber, 'ayah': i},
        ));
      }

      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: ayahs,
      );

      await _player.setAudioSource(playlist, initialIndex: initialIndex);
      await _player.play();
    } catch (e) {
      debugPrint("Error playing surah: $e");
      rethrow;
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Jumps to a specific ayah by index
  Future<void> jumpToAyah(int index) async {
    await _player.seek(Duration.zero, index: index);
    if (!isPlaying) {
      await _player.play();
    }
  }

  Future<void> seekToNext() async {
    await _player.seekToNext();
  }

  Future<void> seekToPrevious() async {
    await _player.seekToPrevious();
  }

  void dispose() {
    _player.dispose();
  }
}
