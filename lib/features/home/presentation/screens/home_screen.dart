import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../tree/presentation/widgets/lottie_tree_widget.dart';
import '../../../tasks/data/datasources/local_task_datasource.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../../prayer/data/repositories/prayer_times_repository.dart';
import '../widgets/task_list_card.dart';
import '../widgets/vicdan_score_card.dart';
import '../widgets/placeholder_tab.dart';
import '../../../prayer/presentation/screens/prayer_screen.dart';
import '../../../quran/presentation/screens/quran_screen.dart';
import '../../../tasks/presentation/screens/task_history_screen.dart';
import 'daily_summary_screen.dart';
import '../../../../features/journey/presentation/screens/journey_screen.dart';
import '../../../../features/profile/presentation/screens/profile_home_screen.dart';
import '../widgets/mood_bubbles_widget.dart';
import '../widgets/prayer_capsule_widget.dart';

/// Main Home Screen with Tree Tab
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Keys & Navigation
  final GlobalKey<LottieTreeWidgetState> _treeKey = GlobalKey();
  int _currentTabIndex = 0;

  // Tree pulsate animation (for immediate visual feedback)
  late AnimationController _treeScaleController;
  late Animation<double> _treeScaleAnimation;

  // Services
  final _locationService = LocationService();
  final _prayerRepo = PrayerTimesRepository();

  // Repository (Lazy initialization)
  late final TaskRepository _repository;

  // State
  List<TaskEntity> _tasks = [];
  bool _isLoading = true;
  String _locationName = 'Konum Bekleniyor...';
  String _nextPrayerInfo = 'Hesaplanıyor...';

  // Timer & Countdown
  Timer? _timer;
  DateTime? _nextPrayerTime;
  String _nextPrayerName = '';
  String _timeLeftString = '';

  // Dashboard Metrics
  int _healthScore = 0;
  final int _streak = 1;
  int _completedTasks = 0;

  @override
  void initState() {
    super.initState();
    // Initialize tree pulsate controller
    _treeScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _treeScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _treeScaleController, curve: Curves.easeOut),
    );

    _initRepository();
    _initLocationAndPrayer();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _treeScaleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    // Update every second for live countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
    _updateCountdown();
  }

  void _updateCountdown() {
    if (_nextPrayerTime == null) return;

    final now = DateTime.now();
    final difference = _nextPrayerTime!.difference(now);

    if (difference.isNegative) {
      _initLocationAndPrayer(); // Refresh
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;

      String timeLeft = '';
      if (hours > 0) {
        timeLeft =
            '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        timeLeft = '$minutes:${seconds.toString().padLeft(2, '0')}';
      }

      if (mounted) {
        setState(() {
          _timeLeftString = timeLeft; // Updated for capsule
          _nextPrayerInfo = "$_nextPrayerName vaktine $timeLeft";
        });
      }
    }
  }

  Future<void> _initRepository() async {
    try {
      // Initialize (Dependencies should ideally be injected)
      _repository = TaskRepositoryImpl(LocalTaskDataSource());

      // Check for daily reset (e.g. if new day started)
      await _repository.checkAndResetDailyTasks();

      await _refreshData();
    } catch (e) {
      debugPrint("Error initializing tasks: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Optionally show error state in UI
        });
      }
    }
  }

  Future<void> _initLocationAndPrayer({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Try Cache First (if not forcing refresh)
      if (!forceRefresh) {
        final cachedLat = prefs.getDouble('latitude');
        final cachedLng = prefs.getDouble('longitude');
        final cachedLoc = prefs.getString('location_name');

        // Auto-refresh if the cached location was "Merkez", forcing the new service logic to run.
        bool needsFix = false;
        if (cachedLoc != null) {
          final lower = cachedLoc.toLowerCase();
          if (lower.contains('merkez') || lower.contains('bilinmeyen')) {
            needsFix = true;
          }
        }

        if (cachedLat != null &&
            cachedLng != null &&
            cachedLoc != null &&
            !needsFix) {
          final prayerData = _prayerRepo.getPrayerTimes(cachedLat, cachedLng);
          if (mounted) {
            setState(() {
              _locationName = cachedLoc;
              _nextPrayerName = prayerData['next_prayer_name'];
              _nextPrayerTime = prayerData['next_prayer_datetime'] as DateTime?;
            });
            _updateCountdown();
          }
          return;
        }
      }

      // 2. Fetch Fresh Data
      final position = await _locationService.determinePosition();
      final details = await _locationService.getLocationDetails(position);
      final city = details['city'] ?? '';
      var district = details['district'] ?? '';

      // Fallback: If district matches city (case-insensitive), try neighborhood or default
      if (district.isEmpty || district.toLowerCase() == city.toLowerCase()) {
        if (details['neighborhood'] != null &&
            details['neighborhood']!.isNotEmpty) {
          district = details['neighborhood']!;
        } else {
          district = "Merkez";
        }
      }

      // Display Logic: "Şehir değil, ilçe yazsın"
      String displayLoc = '';
      if (district.isNotEmpty && district.toLowerCase() != 'merkez') {
        displayLoc = district; // Show JUST "Darıca"
      } else {
        // If "Merkez" or empty, show "Kocaeli Merkez"
        displayLoc = '$city Merkez';
      }

      // Safety: If still empty (no city even), shows Bilinmeyen
      if (displayLoc.trim() == 'Merkez') displayLoc = 'Bilinmeyen Konum';
      if (displayLoc.trim().isEmpty)
        displayLoc = city.isNotEmpty ? '$city Merkez' : 'Konum Alınamadı';

      // 3. Save to Cache
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      await prefs.setString('location_name', displayLoc);

      final prayerData =
          _prayerRepo.getPrayerTimes(position.latitude, position.longitude);
      final nextPName = prayerData['next_prayer_name'];
      final nextPTime = prayerData['next_prayer_datetime'] as DateTime?;

      if (mounted) {
        setState(() {
          _locationName = displayLoc;
          _nextPrayerName = nextPName;
          _nextPrayerTime = nextPTime;
        });
        _updateCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationName = 'Konum Alınamadı';
          _nextPrayerInfo = '-';
          _nextPrayerName = '';
          _nextPrayerTime = null;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    final tasks = await _repository.getDailyTasks();
    final score = await _repository.calculateDailyScore();

    if (mounted) {
      setState(() {
        _tasks = List<TaskEntity>.from(
            tasks); // Ensure it's a list of entities, not models
        _healthScore = score;
        _completedTasks = tasks.where((t) => t.isCompleted).length;
        _isLoading = false;
      });
    }
  }

  Future<bool> _onTaskToggle(String taskId, bool completed) async {
    if (completed) {
      // Show Conscience Dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Vicdan Muhasebesi',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: const Text(
            'Bu görevi gerçekten kalben ve bedenen yerine getirdin mi?\n\nVicdanın rahat mı?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: const Text('Henüz Değil',
                  style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm
              child: const Text(
                'Evet, Huzurluyum',
                style: TextStyle(
                    color: AppColors.goldenHour, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return false;
    }

    // Optimistic Update (UI first)
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        // Create copy with new status
        final updatedTask = _tasks[index].copyWith(isCompleted: completed);
        _tasks[index] = updatedTask;
        _completedTasks = _tasks.where((t) => t.isCompleted).length;
      }
    });

    try {
      // DB Update
      await _repository.toggleTaskCompletion(taskId, completed);
      final newScore = await _repository.calculateDailyScore();

      if (mounted) {
        setState(() {
          _healthScore = newScore;
        });
      }

      // Trigger tree animation
      if (completed) {
        // Combine shake for immediate feedback and glow for celebration
        _treeKey.currentState?.shake();

        // Also trigger the pulsate animation for immediate visual "life"
        _treeScaleController
            .forward()
            .then((_) => _treeScaleController.reverse());
      }
      return true;
    } catch (e) {
      // Revert optimism on error
      _refreshData();
      return false;
    }
  }

  // Drawer Animation State
  bool _isDrawerOpen = false;
  double _xOffset = 0;
  double _yOffset = 0;
  double _scaleFactor = 1;
  double _angle = 0;

  void _toggleDrawer() {
    setState(() {
      if (_isDrawerOpen) {
        _xOffset = 0;
        _yOffset = 0;
        _scaleFactor = 1;
        _angle = 0;
        _isDrawerOpen = false;
      } else {
        _xOffset = 250;
        _yOffset = 80; // Slide down slightly
        _scaleFactor = 0.85;
        _angle = -0.05; // -3 degrees tilt
        _isDrawerOpen = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current screen based on tab index
    Widget currentScreen;
    switch (_currentTabIndex) {
      case 0:
        currentScreen = _buildHomeTab();
        break;
      case 1:
        currentScreen = const PrayerScreen();
        break;
      case 2:
        currentScreen = const QuranScreen();
        break;
      case 3:
        currentScreen = const PlaceholderTab(title: 'Görevler (Yakında)');
        break;
      case 4:
        currentScreen = const ProfileHomeScreen();
        break;
      default:
        currentScreen = _buildHomeTab();
    }

    // Force strict light theme gradient background
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundTop,
      body: Stack(
        children: [
          // 0. Background Gradient (Global)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 1. The Glass Menu (Background Layer)
          SafeArea(child: _buildMenuContent()),

          // 2. The Main Screen (Foreground Layer)
          AnimatedContainer(
            transform: Matrix4.translationValues(_xOffset, _yOffset, 0)
              ..scale(_scaleFactor)
              ..rotateZ(_angle),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white, // Canvas color for the screen content
              borderRadius: BorderRadius.circular(_isDrawerOpen ? 30 : 0),
              boxShadow: [
                if (_isDrawerOpen)
                  BoxShadow(
                    color: AppColors.glassShadow.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(-10, 10),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isDrawerOpen ? 30 : 0),
              // We wrap the content in Scaffold/SafeArea logic internally
              child: Scaffold(
                backgroundColor:
                    Colors.transparent, // Transparent to show container color
                body: Stack(
                  children: [
                    // Screen Content
                    SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          // Custom Header (Only show if we are NOT on a screen that has its own app bar,
                          // strictly usually Home has this custom header.
                          // For simplicity, we keep the header logic if index == 0, else generic app bar?)
                          // User wants "Tuşsuz" flow. Let's keep the header accessible everywhere
                          // or let screens define it.
                          // For now, let's inject our Menu Button into the currentScreen if possible,
                          // OR keep the header always at top.

                          if (_currentTabIndex == 0) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                              child: _buildHeader(),
                            ),
                          ] else ...[
                            // For other screens, we need a way to open drawer.
                            // Adding a custom small header or ensuring screens have it.
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                              child: Row(
                                children: [
                                  GlassIconButton(
                                    icon: _isDrawerOpen
                                        ? Icons.arrow_back
                                        : Icons.grid_view_rounded,
                                    onTap: _toggleDrawer,
                                    size: 44,
                                    iconSize: 22,
                                  ),
                                  const Spacer(),
                                  // Maybe Title?
                                ],
                              ),
                            ),
                          ],

                          // The Screen Body
                          Expanded(child: currentScreen),
                        ],
                      ),
                    ),

                    // Glass Overlay to prevent interaction when drawer is open
                    if (_isDrawerOpen)
                      GestureDetector(
                        onTap: _toggleDrawer,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Refactored Menu Content (Background Layer)
  Widget _buildMenuContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 40, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ]),
                child:
                    const Icon(Icons.favorite, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "VİCDAN",
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        fontFamily:
                            'Playfair Display' // Assuming font exists or fallback
                        ),
                  ),
                  Text(
                    "Hoş Geldin, Sinan",
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            ],
          ),

          const Spacer(flex: 1),

          // Menu Items
          _buildMenuItem(Icons.park_rounded, "Yaşam Alanı", 0),
          _buildMenuItem(Icons.mosque_rounded, "Namaz Vakti", 1),
          _buildMenuItem(Icons.menu_book_rounded, "Kur'an-ı Kerim", 2),
          _buildMenuItem(Icons.check_circle_outline_rounded, "Görevler", 3),
          _buildMenuItem(Icons.person_outline_rounded, "Profil & Ayarlar", 4),

          const Spacer(flex: 2),

          // Footer Actions
          _buildMenuAction(Icons.map_rounded, "30 Günlük Yolculuk", () {
            _toggleDrawer();
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const JourneyScreen()));
          }),
          _buildMenuAction(Icons.calendar_today_rounded, "Günlük Özet", () {
            _toggleDrawer();
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DailySummaryScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    bool isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentTabIndex = index);
        _toggleDrawer();
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.white, width: 1) : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textDark.withOpacity(0.6),
                size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textDark
                    : AppColors.textDark.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuAction(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark.withOpacity(0.5), size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textDark.withOpacity(0.5),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The main "Tree & Dashboard" view (Index 0)
  Widget _buildHomeTab() {
    return Column(
      children: [
        // Tree Area (Living Sanctuary)
        Expanded(
          flex: 5, // Increased space for the tree & bubbles
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. The Tree
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ScaleTransition(
                  scale: _treeScaleAnimation,
                  child: LottieTreeWidget(
                    key: _treeKey,
                    healthScore: _healthScore,
                    onTap: () {
                      // Handled internally
                    },
                  ),
                ),
              ),

              // 2. Mood Bubbles (Floating around)
              const MoodBubblesWidget(),

              // 3. Prayer Capsule (Dynamic Island at Bottom)
              Positioned(
                bottom: 0,
                child: PrayerCapsuleWidget(
                  nextPrayerName: _nextPrayerName,
                  timeRemaining: _timeLeftString,
                ),
              ),
            ],
          ),
        ),

        // Cards Area
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Vicdan Score Card (Simplified)
                VicDanScoreCard(
                  score: _healthScore,
                  streak: _streak,
                  nextPrayer: _nextPrayerInfo,
                ),
                const SizedBox(height: 12),

                // Task List Card
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryGreen))
                      : TaskListCard(
                          tasks: _tasks,
                          completedCount: _completedTasks,
                          onTaskToggle: _onTaskToggle,
                          onHistoryTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TaskHistoryScreen(),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Header with Location or Error Banner
  Widget _buildHeader() {
    // Check if location failed (permission or disabled)
    final hasLocationError = _locationName.contains('Alınamadı');

    if (hasLocationError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Konum Alınamadı',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Namaz vakitleri için lütfen konum izni verin.',
                    style: TextStyle(
                      color: AppColors.error.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Refresh Button
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.error),
              onPressed: _initLocationAndPrayer, // Retry
            ),
          ],
        ),
      );
    }

    // Standard Header
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Centered vertically
      children: [
        // Modern Menu Button
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GlassIconButton(
            icon: _isDrawerOpen
                ? Icons.arrow_back
                : Icons.grid_view_rounded, // Toggles icon
            onTap: _toggleDrawer, // Opens custom drawer
            size: 44,
            iconSize: 22,
          ),
        ),

        // Location Info
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.accentGold, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _locationName,
                  style: const TextStyle(
                    color: AppColors.textDark, // Dark text on light bg
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Notification Button
        GlassIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
          size: 44,
          iconSize: 22,
        ),
      ],
    );
  }
}
