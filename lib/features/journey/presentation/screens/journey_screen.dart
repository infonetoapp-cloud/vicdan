import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/journey_data.dart';
import '../../data/mahya_data.dart';
import '../../data/repositories/journey_repository.dart';
import '../widgets/journey_card.dart';
import '../widgets/digital_mahya_widget.dart';
import '../../../../features/prayer/data/repositories/prayer_times_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../../features/quran/presentation/screens/quran_screen.dart';
import '../../../../features/quran/data/juz_data.dart';
import '../../../../features/quran/data/datasources/quran_local_datasource.dart';
import '../../../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../../../features/quran/presentation/screens/reading_screen.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  // Services
  final _repository = JourneyRepository();
  final _prayerRepo = PrayerTimesRepository();

  // State
  Set<int> _unlockedDays = {};
  Set<int> _completedDays = {};
  Set<int> _teravihDays = {};
  Set<int> _hatimDays = {};
  bool _isSeasonStarted = false;
  Duration? _timeUntilRamadan;
  Timer? _countdownTimer;

  // Prayer Logic
  String? _nextPrayerName;
  Duration? _timeUntilPrayer;
  DateTime? _nextPrayerTime;

  // Pagination
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadJourneyStatus();
    _loadPrayerTimes(); // New logic
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadJourneyStatus() async {
    final unlocked = _repository.getUnlockedDays();
    final completed = await _repository.getCompletedDays();
    final teravih = await _repository.getTeravihDays();
    final hatim = await _repository.getHatimDays();

    // Check if season started
    final now = DateTime.now();
    final start = _repository.ramadanStart;
    final isStarted =
        now.isAfter(start) || now.isAtSameMomentAs(start); // Or just enabled

    // Calculate time until
    final diff = start.difference(now);

    if (mounted) {
      setState(() {
        _unlockedDays = unlocked;
        _completedDays = completed;
        _teravihDays = teravih;
        _hatimDays = hatim;
        _isSeasonStarted = isStarted ||
            unlocked.isNotEmpty; // If unlocked has days, it started
        _timeUntilRamadan = diff.isNegative ? null : diff;
      });
    }
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition();
      final data =
          _prayerRepo.getPrayerTimes(position.latitude, position.longitude);

      final nextTime = data['next_prayer_datetime'] as DateTime?;
      final nextName = data['next_prayer_name'] as String?;

      if (nextTime != null && nextName != null && mounted) {
        setState(() {
          _nextPrayerTime = nextTime;

          // Custom Logic for Iftar/Sahur
          // If next is Aksam -> Iftar
          // If next is Imsak -> Sahur

          if (nextName == 'Akşam') {
            _nextPrayerName = 'İftara Kalan Süre';
          } else if (nextName == 'İmsak') {
            _nextPrayerName = 'Sahura Kalan Süre';
          } else {
            // For other times, maybe just show next prayer?
            // Or hide? The user specifically asked for "İftar/Sahur Sayacı"
            // I will show generic "Vaktine Kalan" for others, or prioritize Iftar/Sahur.
            // If it's noon, technically we are waiting for Iftar eventually.
            // But let's stick to "Next Prayer" generally, but label explicitly for Iftar/Sahur.
            _nextPrayerName = '$nextName Vaktine Kalan';
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading prayer times: $e");
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      // Ramadan Countdown
      final start = _repository.ramadanStart;
      final diffRamadan = start.difference(now);

      if (diffRamadan.isNegative) {
        // Season Started
        if (!_isSeasonStarted) _loadJourneyStatus();
      } else {
        if (mounted) setState(() => _timeUntilRamadan = diffRamadan);
      }

      // Prayer Countdown
      if (_nextPrayerTime != null) {
        final diffPrayer = _nextPrayerTime!.difference(now);
        if (diffPrayer.isNegative) {
          _loadPrayerTimes(); // Refresh for next prayer
        } else {
          if (mounted) setState(() => _timeUntilPrayer = diffPrayer);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sahur Mode & Kadir Night Logic
    final now = DateTime.now();
    final isSahurMode = now.hour >= 2 && now.hour < 5;
    final ramadanDay = _calculateCurrentRamadanDay();
    final isKadirNight = _isSeasonStarted && ramadanDay == 27;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Ramazan Yolculuğu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          if (isKadirNight)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.auto_awesome, color: AppColors.goldenHour),
            ),
        ],
      ),
      body: InteractiveSkyBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Header / Quote
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GlassCard(
                      opacity: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (!_isSeasonStarted &&
                                _timeUntilRamadan != null) ...[
                              const Text(
                                "Ramazan'a Kalan Süre",
                                style: TextStyle(
                                    color: AppColors.goldenHour, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDuration(_timeUntilRamadan!),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter'),
                              ),
                              const SizedBox(height: 8),
                            ] else if (_nextPrayerName != null &&
                                _timeUntilPrayer != null) ...[
                              // IFTAR / SAHUR COUNTER
                              Text(
                                _nextPrayerName!,
                                style: const TextStyle(
                                    color: AppColors.goldenHour, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDuration(_timeUntilPrayer!),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter'),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Digital Mahya
                            DigitalMahyaWidget(
                              message: _isSeasonStarted
                                  ? MahyaData.getMessageForDay(
                                      _calculateCurrentRamadanDay())
                                  : "HOŞ GELDİN YA ŞEHR-İ RAMAZAN",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // The Grid
                  // The Grid (Paginated)
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: 3, // 30 items / 10 per page = 3 pages
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, pageIndex) {
                              final startIndex = pageIndex * 10;
                              final endIndex = (startIndex + 10)
                                  .clamp(0, JourneyData.allItems.length);
                              final pageItems = JourneyData.allItems
                                  .sublist(startIndex, endIndex);

                              return GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                physics:
                                    const NeverScrollableScrollPhysics(), // Scroll via PageView
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: pageItems.length,
                                itemBuilder: (context, index) {
                                  final item = pageItems[index];
                                  final isUnlocked =
                                      _unlockedDays.contains(item.day);
                                  final isCompleted =
                                      _completedDays.contains(item.day);

                                  return JourneyCard(
                                    item: item,
                                    status: isCompleted
                                        ? JourneyCardStatus.completed
                                        : isUnlocked
                                            ? JourneyCardStatus.unlocked
                                            : JourneyCardStatus.locked,
                                    onTap: () => _handleDayTap(item.day),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // Page Indicators
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppColors.goldenHour
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // SAHUR MODE OVERLAY
            if (isSahurMode)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color:
                        const Color(0xFF0F172A).withOpacity(0.5), // Slate 900
                  ),
                ),
              ),

            // KADIR NIGHT VISUALS (Subtle stars)
            if (isKadirNight)
              Positioned(
                top: 50,
                right: 30,
                child: IgnorePointer(
                  child: Icon(Icons.star_rate_rounded,
                      color: Colors.white.withOpacity(0.2), size: 100),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleDayTap(int day) {
    if (!_unlockedDays.contains(day)) {
      // Locked feedback
      HapticFeedback.lightImpact();

      String message = '$day. Gün henüz açılmadı.';
      if (!_isSeasonStarted) {
        message = 'Ramazan yaklaşıyor... Sabırlı ol 🌿';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.black54,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Open detail modal (Placeholder for now)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDetailModal(day),
    );
  }

  Widget _buildDetailModal(int day) {
    final item = JourneyData.allItems.firstWhere((e) => e.day == day);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.98), // Opaque background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: StatefulBuilder(
          // Use StatefulBuilder to update local state immediately
          builder: (context, setModalState) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, color: Colors.white24),
            const SizedBox(height: 30),
            Text(
              "$day. GÜN",
              style: const TextStyle(
                color: AppColors.goldenHour,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                item.content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),

            // TRACKERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTrackerOption(
                        label: "Teravih Kıldım",
                        isSelected: _teravihDays.contains(day),
                        onTap: () async {
                          final newVal = !_teravihDays.contains(day);
                          await _repository.toggleTeravih(day, newVal);
                          await _loadJourneyStatus(); // Update parent
                          setModalState(() {}); // Update local modal state
                          setState(() {}); // Update parent screen state
                        }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTrackerOption(
                      label: "Cüz Oku ($day. Cüz)",
                      isSelected: _hatimDays.contains(day),
                      isAction: true, // Special styling for action
                      onTap: () async {
                        // Toggle logic
                        final newVal = !_hatimDays.contains(day);
                        await _repository.toggleHatim(day, newVal);
                        await _loadJourneyStatus();
                        setModalState(() {});
                        setState(() {});
                      },
                      onActionTap: () => _navigateToJuz(day),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(30),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sage,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await _repository.markDayCompleted(day);
                    await _loadJourneyStatus(); // Refresh UI
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Tamamla",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  int _calculateCurrentRamadanDay() {
    final now = DateTime.now();
    final start = _repository.ramadanStart;
    final diff = now.difference(start).inDays;
    return diff + 1;
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      return '${d.inDays} Gün';
    }
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '${hours}s ${minutes}dk ${seconds}sn';
  }

  Widget _buildTrackerOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isAction = false,
    VoidCallback? onActionTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sage.withOpacity(0.2)
              : Colors.white
                  .withOpacity(0.1), // Slightly more opaque unselected
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.sage : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.sage : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isAction && onActionTap != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onActionTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.goldenHour.withOpacity(0.5))),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded,
                          size: 14, color: AppColors.goldenHour),
                      SizedBox(width: 4),
                      Text("Oku",
                          style: TextStyle(
                              color: AppColors.goldenHour, fontSize: 11)),
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToJuz(int day) async {
    try {
      // 1. Get Juz Start Info
      final juzInfo = JuzData.getJuzStart(day);
      final surahNumber = juzInfo['surah']!;
      final ayahNumber = juzInfo['ayah']!;

      // 2. Fetch Surah
      // Instantiate repository directly (TODO: Use DI)
      final quranParams = QuranLocalDataSource();
      final quranRepo = QuranRepositoryImpl(quranParams);

      final surah = await quranRepo.getSurahByNumber(surahNumber);

      if (surah != null && mounted) {
        // 3. Navigate
        Navigator.pop(context); // Close modal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadingScreen(
              surah: surah,
              startAyahNumber: ayahNumber,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error navigating to juz: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata: Veri yüklenemedi. ($e)"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
