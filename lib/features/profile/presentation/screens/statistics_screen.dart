import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/user_stats.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../tasks/data/datasources/local_task_datasource.dart';

/// Statistics Screen
/// Displays charts and detailed analytics about user performance.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late ProfileRepositoryImpl _profileRepo;
  List<Map<String, dynamic>> _scoreHistory = [];
  UserStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final taskDataSource = LocalTaskDataSource();
    final taskRepo = TaskRepositoryImpl(taskDataSource);
    _profileRepo = ProfileRepositoryImpl(taskRepo);

    final history = await _profileRepo.getHealthScoreHistory(14);
    final stats = await _profileRepo.getUserStats();

    if (mounted) {
      setState(() {
        _scoreHistory = history;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'İstatistikler',
          style:
              TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vicdan Skoru Trendi',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Son 14 günlük performansın',
            style: TextStyle(color: AppColors.textDark, fontSize: 13),
          ),
          const SizedBox(height: 16),
          GlassCard(
            opacity: 0.8,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: _buildLineChart(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Özet',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: _buildSummaryRow(),
          ),
          const SizedBox(height: 32),
          GlassCard(
            opacity: 0.8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_rounded,
                      color: AppColors.primaryGreen, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    "Kur'an Okuma İstatistikleri",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toplam Okuma Süresi: ${_isLoading ? '...' : _stats?.quranReadingMinutes ?? 0} Dakika',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    if (_scoreHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                color: AppColors.primaryGreen, size: 48),
            SizedBox(height: 16),
            Text(
              'Henüz veri toplanmadı',
              style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Görevlerini tamamladıkça burası yeşerecek 🌿',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final spots = _scoreHistory.asMap().entries.map((entry) {
      return FlSpot(
          entry.key.toDouble(), (entry.value['score'] as num).toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textDark.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style:
                      const TextStyle(color: AppColors.textDark, fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 2,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _scoreHistory.length) {
                  final date = _scoreHistory[index]['date'] as DateTime;
                  return Text(
                    '${date.day}',
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: _scoreHistory.length > 1
            ? (_scoreHistory.length - 1).toDouble()
            : 1.0,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primaryGreen,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primaryGreen,
                  strokeWidth: 2,
                  strokeColor: AppColors.primaryGreen,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.3),
                  AppColors.primaryGreen.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final average = _scoreHistory.isNotEmpty
        ? _scoreHistory
                .map((e) => (e['score'] as num).toInt())
                .reduce((a, b) => a + b) ~/
            _scoreHistory.length
        : 0;

    final bestDay = _scoreHistory.isNotEmpty
        ? _scoreHistory
            .map((e) => (e['score'] as num).toInt())
            .reduce((a, b) => a > b ? a : b)
        : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: _buildSummaryCard(
            icon: Icons.trending_up,
            label: 'Ortalama',
            value: '$average',
            color: AppColors.sage,
          ),
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: _buildSummaryCard(
            icon: Icons.star,
            label: 'En İyi Gün',
            value: '$bestDay',
            color: AppColors.goldenHour,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassCard(
      opacity: 0.8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
