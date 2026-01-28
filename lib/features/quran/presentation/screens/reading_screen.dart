import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../domain/entities/surah.dart';
import '../../data/datasources/quran_audio_service.dart';
import '../widgets/ayah_widget.dart';
import '../widgets/quran_audio_player.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Reading screen for displaying all ayahs of a surah
class ReadingScreen extends StatefulWidget {
  final Surah surah;
  final int? startAyahNumber; // 1-based Ayah number

  const ReadingScreen({
    super.key,
    required this.surah,
    this.startAyahNumber,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final QuranAudioService _audioService = QuranAudioService();
  final PreferencesService _prefsService = PreferencesService();

  int? _currentAyahIndex;
  Set<int> _bookmarkedAyahs = {};

  @override
  void initState() {
    super.initState();
    if (widget.startAyahNumber != null) {
      _jumpToStartAyah();
    } else {
      _restoreLastRead();
    }

    _audioService.currentAyahIndexStream.listen((index) {
      if (index != null && mounted) {
        setState(() {
          _currentAyahIndex = index;
        });
        _scrollToAyah(index);
        _saveProgress(index);
      }
    });
  }

  void _jumpToStartAyah() {
    final index = widget.startAyahNumber! - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay slightly to ensure list is built
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _scrollToAyah(index);
          setState(() {
            _currentAyahIndex = index;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.startAyahNumber}. Ayet\'e gidildi'),
              backgroundColor: AppColors.goldenHour,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    });
  }

  Future<void> _restoreLastRead() async {
    final lastRead = await _prefsService.getLastRead();
    if (lastRead != null && lastRead['surah'] == widget.surah.number) {
      final ayahIndex = lastRead['ayah']! - 1; // 0-based

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _scrollToAyah(ayahIndex);
            setState(() {
              _currentAyahIndex = ayahIndex;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Kaldığınız yerden devam ediliyor: ${lastRead['ayah']}. Ayet'),
                backgroundColor: AppColors.goldenHour,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      });
    }
  }

  Future<void> _saveProgress(int index) async {
    await _prefsService.saveLastRead(widget.surah.number, index + 1);
  }

  void _scrollToAyah(int index) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index + 1, // +1 for header
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.3,
      );
    }
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: widget.surah.ayahs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildSurahHeader();
                        }

                        final ayahIndex = index - 1;
                        final ayah = widget.surah.ayahs[ayahIndex];

                        return AyahWidget(
                          ayah: ayah,
                          isBookmarked: _bookmarkedAyahs.contains(ayah.number),
                          isActive: _currentAyahIndex == ayahIndex,
                          onTap: () => _onAyahTap(ayahIndex),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: QuranAudioPlayer(
                  surahNumber: widget.surah.number,
                  surahName: widget.surah.nameTurkish,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.surah.nameTurkish,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.surah.nameArabic} • ${widget.surah.totalAyahs} Ayet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          // Visible Header Play Button (Secondary)
          IconButton(
            onPressed: () {
              if (!_audioService.isPlaying) {
                _playAudioSafe(0); // Play from beginning
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.goldenHour.withOpacity(0.8), // More visible
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldenHour.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.surah.nameArabic,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.surah.nameTurkish,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),
          if (widget.surah.number != 9) ...[
            const SizedBox(height: 8),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 2,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  void _onAyahTap(int index) {
    if (!_audioService.isPlaying) {
      _playAudioSafe(index);
    } else {
      _audioService.jumpToAyah(index);
    }
  }

  Future<void> _playAudioSafe(int initialIndex) async {
    try {
      await _audioService.playSurah(
        widget.surah.number,
        widget.surah.totalAyahs,
        initialIndex: initialIndex,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'Ayarlar',
              textColor: Colors.white,
              onPressed: () {}, // Open wifi settings if possible (future)
            ),
          ),
        );
      }
    }
  }
}
