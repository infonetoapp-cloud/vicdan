import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/local_task_datasource.dart';
import '../../domain/entities/task_history_entity.dart';

class TaskHistoryScreen extends StatefulWidget {
  const TaskHistoryScreen({super.key});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  late final TaskRepository _repository;
  List<TaskHistoryEntity> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Manual DI for MVP consistency
    _repository = TaskRepositoryImpl(LocalTaskDataSource());
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.getHistory(30);
    if (mounted) {
      setState(() {
        _history = history;
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
        title: const Text("İstikrar Tablosu",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SkyGradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Summary Card
                      GlassCard(
                        child: Column(
                          children: [
                            const Text(
                              "Son 30 Gün",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${_calculateAverageScore()}%",
                              style: const TextStyle(
                                color: AppColors.goldenHour,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Ortalama Başarı",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
                                "${date.year}-${date.month}-${date.day}";

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
    if (_history.isEmpty) return 0;
    final sum = _history.fold(0, (prev, element) => prev + element.totalScore);
    return (sum / _history.length).round();
  }

  Widget _buildDayCell(TaskHistoryEntity item, DateTime date) {
    final score = item.totalScore;
    Color color = Colors.white.withOpacity(0.05); // Default empty

    if (score > 0) {
      if (score < 40)
        color = Colors.green.withOpacity(0.3);
      else if (score < 70)
        color = Colors.green.withOpacity(0.6);
      else
        color = Colors.green;
    }

    final isToday =
        date.day == DateTime.now().day && date.month == DateTime.now().month;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border:
            isToday ? Border.all(color: AppColors.goldenHour, width: 2) : null,
      ),
      child: Center(
        child: Text(
          "${date.day}",
          style: TextStyle(
            color: Colors.white.withOpacity(score > 0 ? 1 : 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
