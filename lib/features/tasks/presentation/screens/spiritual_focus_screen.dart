import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../tasks/data/datasources/local_task_datasource.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../home/presentation/widgets/task_list_card.dart';

class SpiritualFocusScreen extends StatefulWidget {
  const SpiritualFocusScreen({super.key});

  @override
  State<SpiritualFocusScreen> createState() => _SpiritualFocusScreenState();
}

class _SpiritualFocusScreenState extends State<SpiritualFocusScreen> {
  final _repository = TaskRepositoryImpl(LocalTaskDataSource());
  List<TaskEntity> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await _repository.getDailyTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildIntentionCard(),
              const SizedBox(height: 24),
              _buildReflectionCard(),
              const SizedBox(height: 32),
              _buildGoodnessSeeds(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manevi Odak',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Kalbin ve vicdanın bugün için rehberi',
          style: TextStyle(
            color: AppColors.textDark.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildIntentionCard() {
    return GlassCard(
      opacity: 0.8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wb_sunny_rounded,
                  color: AppColors.accentGold, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'Günün Niyeti',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '"Bugün her sözümde bir hayır, her adımımda bir nezaket arayacağım."',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                fontFamily: 'Playfair Display',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard() {
    return GlassCard(
      opacity: 0.6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined,
                    color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tefekkür Köşesi',
                  style: TextStyle(
                    color: AppColors.textDark.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'En son ne zaman bir nefesin kıymetini derinden hissettin?',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoodnessSeeds() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İyilik Tohumları',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TaskListCard(
          tasks: _tasks,
          completedCount: _tasks.where((t) => t.isCompleted).length,
          onTaskToggle: (id, completed) async {
            await _repository.toggleTaskCompletion(id, completed);
            _loadData();
            return true;
          },
          onHistoryTap: () {},
        ),
      ],
    );
  }
}
