import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/local_task_datasource.dart';
import '../../domain/entities/task_history_entity.dart';
import 'dart:async';

class TaskHistoryScreen extends StatefulWidget {
  const TaskHistoryScreen({super.key});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  late final TaskRepository _repository;
  List<TaskHistoryEntity> _history = [];
  bool _isLoading = true;
  int _todayScore = 0;

  @override
  void initState() {
    super.initState();
    // Manual DI for MVP consistency
    _repository = TaskRepositoryImpl(LocalTaskDataSource());
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.getHistory(30);
    final todayScore = await _repository.calculateDailyScore();

    if (mounted) {
      setState(() {
        _history = history;
        _todayScore = todayScore;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('İstikrar Tablosu',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.bold)),
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
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGreen))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Summary Card
                      GlassCard(
                        opacity: 0.8,
                        child: Column(
                          children: [
                            const Text(
                              'Son 30 Gün',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_calculateAverageScore()}%',
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Ortalama Başarı',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Heatmap Grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7, // Days of week
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 30,
                          itemBuilder: (context, index) {
                            // Reverse index to show latest at bottom right or top left?
                            // Usually calendars are chronological.
                            // Let's assume index 0 is 29 days ago, index 29 is today.
                            // Or better: Let's map actual dates.
                            // We have _history aligned by date. But _history might be sparse.
                            // We need to construct a full list of 30 days.

                            final date = DateTime.now()
                                .subtract(Duration(days: 29 - index));
                            final dateStr =
                                '${date.year}-${date.month}-${date.day}';

                            final historyItem = _history.firstWhere(
                                (h) => h.date == dateStr,
                                orElse: () => TaskHistoryEntity(
                                    date: dateStr,
                                    totalScore: 0,
                                    completedCount: 0,
                                    totalCount: 0));

                            return _buildDayCell(historyItem, date);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  int _calculateAverageScore() {
    // Include today's score in average calculation
    final historyScores = _history.map((e) => e.totalScore).toList();
    historyScores.add(_todayScore);

    if (historyScores.isEmpty) return 0;
    final sum = historyScores.reduce((a, b) => a + b);
    return (sum / historyScores.length).round();
  }

  Widget _buildDayCell(TaskHistoryEntity item, DateTime date) {
    var score = item.totalScore;

    // If this is today, override with live score
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    if (isToday) {
      score = _todayScore;
    }

    Color color = AppColors.primaryGreen.withOpacity(0.05); // Default empty

    if (score > 0) {
      if (score < 40) {
        color = AppColors.primaryGreen.withOpacity(0.2);
      } else if (score < 70)
        color = AppColors.primaryGreen.withOpacity(0.5);
      else
        color = AppColors.primaryGreen;
    }

    // Today logic handled above in score assignment

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border:
            isToday ? Border.all(color: AppColors.goldenHour, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: score > 70
                ? Colors.white
                : AppColors.textDark.withOpacity(score > 0 ? 1 : 0.4),
            fontSize: 12,
            fontWeight: score > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
