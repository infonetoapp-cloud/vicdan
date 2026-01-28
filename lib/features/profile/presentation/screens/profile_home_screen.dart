import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/user_stats.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../tasks/data/datasources/local_task_datasource.dart';
import '../../../share/presentation/screens/share_center_screen.dart';
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
      debugPrint("Error loading stats: $e");
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
          "Profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button for tab
      ),
      body: SkyGradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
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
        : "?";

    return GlassCard(
      opacity: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldenHour.withOpacity(0.8),
                    AppColors.sage.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldenHour.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _stats?.userName ?? "Yolcu",
              style: const TextStyle(
                color: Colors.white,
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
                  const Icon(Icons.local_fire_department,
                      color: AppColors.goldenHour, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "${_stats?.currentStreak ?? 0} gündür bu yoldasın",
                    style: const TextStyle(
                      color: AppColors.goldenHour,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
            icon: Icons.bolt,
            label: "Vicdan Gücü",
            value: "${_stats?.todayScore ?? 0}",
            color: AppColors.goldenHour,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.whatshot,
            label: "En Uzun Seri",
            value: "${_stats?.longestStreak ?? 0} gün",
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            label: "Toplam",
            value: "${_stats?.totalCompletedTasks ?? 0}",
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
      opacity: 0.1,
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
              style: const TextStyle(
                color: Colors.white70,
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
          title: "İstatistikler",
          subtitle: "Detaylı performans analizi",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StatisticsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.share_rounded,
          title: "Paylaşım Merkezi",
          subtitle: "Hikayeni paylaş",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShareCenterScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.settings_rounded,
          title: "Ayarlar",
          subtitle: "Uygulama tercihleri",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.info_outline_rounded,
          title: "Hakkında",
          subtitle: "Versiyon 1.0.0",
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
      opacity: 0.1,
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "VİCDAN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Vicdan Arkadaşı",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "Versiyon 1.0.0",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              "Adım adım, yaprak yaprak 🌿",
              style: TextStyle(color: AppColors.sage, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam",
                style: TextStyle(color: AppColors.goldenHour)),
          ),
        ],
      ),
    );
  }
}
