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
import '../../../prayer/presentation/screens/prayer_screen.dart';
import '../../../quran/presentation/screens/quran_screen.dart';
import '../../../tasks/presentation/screens/task_history_screen.dart';
import '../../../../features/journey/presentation/screens/journey_screen.dart';
import '../../../../features/profile/presentation/screens/settings_screen.dart';
import '../../../../features/profile/presentation/screens/profile_home_screen.dart';
import '../widgets/mood_bubbles_widget.dart';
import '../widgets/prayer_capsule_widget.dart';
import 'package:vicdan_app/features/social/presentation/screens/prayer_feed_screen.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import '../../../tasks/presentation/screens/spiritual_focus_screen.dart';
import '../../../../core/services/adhan_notification_service.dart';

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
    // Force refresh to update location name format (District priority)
    _initLocationAndPrayer(forceRefresh: true);
    _startTimer();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // Permission request delay to arguably improve UX (don't blast immediately)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      await AdhanNotificationService().initialize();
    }
  }

  DateTime? _lastBackPressTime;

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

      // 1. Priority: District (Ilçe)
      if (district.isNotEmpty && district.toLowerCase() != 'merkez') {
        displayLoc = district;
      }
      // 2. Fallback: Neighborhood (Mahalle) if District is missing/Merkez
      else if (details['neighborhood'] != null &&
          details['neighborhood']!.isNotEmpty) {
        displayLoc = details['neighborhood']!;
      }
      // 3. Fallback: City (Sehir)
      else if (city.isNotEmpty) {
        displayLoc = city;
      } else {
        displayLoc = 'Bilinmeyen Konum';
      }

      // Final clean up
      if (displayLoc.trim().isEmpty) displayLoc = 'Konum Alınamadı';

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
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Vicdan Muhasebesi',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Bu görevi gerçekten kalben ve bedenen yerine getirdin mi?\n\nVicdanın rahat mı?',
            style: TextStyle(color: AppColors.textLight, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: Text('Henüz Değil',
                  style:
                      TextStyle(color: AppColors.textLight.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm
              child: const Text(
                'Evet, Huzurluyum',
                style: TextStyle(
                    color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
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
        currentScreen = const SpiritualFocusScreen();
        break;
      case 4:
        currentScreen = const ProfileHomeScreen();
        break;
      case 5:
        currentScreen = const PrayerFeedScreen();
        break;
      default:
        currentScreen = _buildHomeTab();
    }

    // Force strict light theme gradient background
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;

          if (_isDrawerOpen) {
            _toggleDrawer();
            return;
          }

          if (_currentTabIndex != 0) {
            setState(() => _currentTabIndex = 0);
            return;
          }

          final now = DateTime.now();
          if (_lastBackPressTime == null ||
              now.difference(_lastBackPressTime!) >
                  const Duration(seconds: 2)) {
            _lastBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Çıkmak için tekrar basın",
                    style: TextStyle(color: Colors.white)),
                duration: Duration(seconds: 2),
                backgroundColor: AppColors.textDark,
              ),
            );
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.backgroundTop,
          body: Stack(
            children: [
              // 0. Background Gradient (Global)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.backgroundTop,
                      AppColors.backgroundBottom
                    ],
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
                    backgroundColor: Colors
                        .transparent, // Transparent to show container color
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
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 8, 20, 0),
                                  child: _buildHeader(),
                                ),
                              ] else ...[
                                // For other screens, we need a way to open drawer.
                                // Adding a custom small header or ensuring screens have it.
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
        ));
  }

  // Refactored Menu Content (Background Layer)
  Widget _buildMenuContent() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(), // Prevent bounce if not needed
      child: Container(
        height: MediaQuery.of(context).size.height, // Force full height
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        child: SafeArea(
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
                    child: const Icon(Icons.favorite,
                        color: AppColors.primaryGreen),
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

              const SizedBox(height: 40),

              // Menu Items
              // Menu Items
              _buildMenuItem(Icons.park_rounded, "Yaşam Alanı", 0),
              _buildMenuItem(Icons.mosque_rounded, "Namaz Vakti", 1),
              _buildMenuItem(Icons.menu_book_rounded, "Kur'an-ı Kerim", 2),
              _buildMenuItem(Icons.spa_rounded, "Manevi Odak", 3),
              _buildMenuItem(
                  Icons.volunteer_activism_rounded, "Gönül Bağları", 5),

              // Actions in main flow
              _buildMenuAction(Icons.map_rounded, "Ramazan Yolculuğu", () {
                _toggleDrawer();
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JourneyScreen()));
              }),

              const Spacer(), // Pushes Profile to bottom

              // Footer / System
              _buildMenuItem(
                  Icons.person_outline_rounded, "Profil & Ayarlar", 4),

              const SizedBox(height: 20), // Safety padding
            ],
          ),
        ),
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textDark.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
        // Mood Capsules (Placed above the tree to avoid overlap)
        const Padding(
          padding: EdgeInsets.only(top: 4, bottom: 0), // Tightened top padding
          child: MoodBubblesWidget(),
        ),

        // Tree Area (Living Sanctuary)
        Expanded(
          flex: 5, // Reduced from 6 to give more space to cards
          child: Stack(
            alignment: Alignment.topCenter, // Lift tree up
            children: [
              // 1. The Tree (Moved Up)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
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

              // 2. Prayer Capsule (Dynamic Island at Bottom)
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
        // Cards Area (Scrollable to prevent overflow)
        Expanded(
          flex: 7, // Increased from 5 to 7. Major space boost.
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  _isLoading
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
                  // Extra padding for bottom safety
                  const SizedBox(height: 10),
                ],
              ),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          size: 44,
          iconSize: 22,
        ),
      ],
    );
  }
}
