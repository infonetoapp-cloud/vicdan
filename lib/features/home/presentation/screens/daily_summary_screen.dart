import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../../prayer/data/datasources/prayer_checkin_store.dart';
import '../../../tasks/data/datasources/local_task_datasource.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/repositories/task_repository.dart';

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  late final TaskRepository _repository;
  final _checkinStore = PrayerCheckinStore();
  List<TaskEntity> _tasks = [];
  int _score = 0;
  Set<String> _completedPrayers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository = TaskRepositoryImpl(LocalTaskDataSource());
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final tasks = await _repository.getDailyTasks();
    final score = await _repository.calculateDailyScore();
    final completed = await _checkinStore.getCompleted(DateTime.now());
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _score = score;
        _completedPrayers = completed;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('d MMMM EEEE', 'tr_TR').format(DateTime.now());
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();
    final prayerNames = [
      'İmsak',
      'Öğle',
      'İkindi',
      'Akşam',
      'Yatsı',
    ];
    final completedPrayerCount =
        prayerNames.where(_completedPrayers.contains).length;
    return Scaffold(
      body: InteractiveSkyBackground(
        showSlider: false,
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Özet',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    if (_loading)
                      const Expanded(
                        child: Center(
                          child:
                              CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView(
                          children: [
                            GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bugün Ne Oldu?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Görev: ${completedTasks.length}/${_tasks.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Namaz: $completedPrayerCount/${prayerNames.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Vicdan skoru: $_score',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tamamlanan Görevler',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  if (completedTasks.isEmpty)
                                    Text(
                                      'Bugün kendine şefkatli davrandın.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    )
                                  else
                                    ...completedTasks.take(6).map(
                                          (task) => Padding(
                                            padding:
                                                const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              '• ${task.title}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yarın için niyet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Yarın küçük bir adımla başla.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Niyet kaydı yakında')),
                                        );
                                      },
                                      child: const Text('Niyet Et'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: GlassCard(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
