import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/user_stats.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../tasks/data/datasources/local_task_datasource.dart';

import 'statistics_screen.dart';
import 'settings_screen.dart';

/// Profile Home Screen
/// Displays user avatar, streak, quick stats, and navigation to other screens.
class ProfileHomeScreen extends StatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  State<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> {
  late ProfileRepositoryImpl _profileRepo;
  UserStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    final taskDataSource = LocalTaskDataSource();
    final taskRepo = TaskRepositoryImpl(taskDataSource);
    _profileRepo = ProfileRepositoryImpl(taskRepo);
    await _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _profileRepo.getUserStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style:
              TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button for tab
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGreen))
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildMenu(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final initials = _stats?.userName.isNotEmpty == true
        ? _stats!.userName.substring(0, 1).toUpperCase()
        : '?';

    return GlassCard(
      opacity: 0.8, // More opaque for light theme visibility
      borderOpacity: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showAvatarPicker,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.8),
                      AppColors.sage.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: _stats?.avatarUrl != null
                      ? Icon(
                          IconData(int.parse(_stats!.avatarUrl!),
                              fontFamily: 'MaterialIcons'),
                          color: Colors.white,
                          size: 40,
                        )
                      : Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _stats?.userName ?? 'Yolcu',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.goldenHour.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.goldenHour.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.goldenHour, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${_stats?.daysUsingApp ?? 0} gündür vicdanınla berabersin',
                      style: const TextStyle(
                        color: AppColors.goldenHour,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            label: 'Yolculuk',
            value: '${_stats?.daysUsingApp ?? 1} GÜN',
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.auto_awesome_rounded,
            label: 'Seri',
            value: '${_stats?.currentStreak ?? 1}',
            color: AppColors.goldenHour,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.task_alt_rounded,
            label: 'Toplam',
            value: '${_stats?.totalCompletedTasks ?? 0}',
            color: AppColors.sage,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassCard(
      opacity: 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textDark.withOpacity(0.6),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.bar_chart_rounded,
          title: 'İstatistikler',
          subtitle: 'Detaylı performans analizi',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StatisticsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.settings_rounded,
          title: 'Ayarlar',
          subtitle: 'Uygulama tercihleri',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.info_outline_rounded,
          title: 'Hakkında',
          subtitle: 'Versiyon 1.0.0',
          onTap: () => _showAboutDialog(),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      opacity: 1.0, // Fully solid cards for menu
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    final List<IconData> spiritualAvatars = [
      Icons.mosque_rounded,
      Icons.menu_book_rounded,
      Icons.volunteer_activism_rounded,
      Icons.eco_rounded,
      Icons.park_rounded,
      Icons.wb_sunny_rounded,
      Icons.nights_stay_rounded,
      Icons.auto_awesome_rounded,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manevi Avatar Seçin',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: spiritualAvatars.length,
              itemBuilder: (context, index) {
                final icon = spiritualAvatars[index];
                return GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                        'user_avatar', icon.codePoint.toString());
                    if (mounted) {
                      Navigator.pop(context);
                      _loadStats();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.2)),
                    ),
                    child: Icon(icon, color: AppColors.primaryGreen, size: 30),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'VİCDAN',
          style:
              TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vicdan Arkadaşı',
              style: TextStyle(color: AppColors.textDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Versiyon 1.0.0',
              style: TextStyle(
                  color: AppColors.textDark.withOpacity(0.5), fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              'Adım adım, yaprak yaprak 🌿',
              style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam',
                style: TextStyle(color: AppColors.goldenHour)),
          ),
        ],
      ),
    );
  }
}
