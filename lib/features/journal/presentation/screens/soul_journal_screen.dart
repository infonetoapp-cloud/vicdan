import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/journal_repository.dart';

class SoulJournalScreen extends StatefulWidget {
  const SoulJournalScreen({super.key});

  @override
  State<SoulJournalScreen> createState() => _SoulJournalScreenState();
}

class _SoulJournalScreenState extends State<SoulJournalScreen>
    with SingleTickerProviderStateMixin {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await JournalRepository().getEntries();
    setState(() {
      _entries = entries.reversed.toList(); // Newest first
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showEntryDetails(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.accentGold, size: 32),
                const SizedBox(height: 16),
                Text(
                  entry.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Playfair Display',
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDate(entry.date),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Kapat"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Ruh Defteri",
            style:
                TextStyle(color: Colors.white, fontFamily: 'Playfair Display')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027), // Deep Night
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accentGold))
            : _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.nightlight_round,
                            size: 64, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          "Henüz gökyüzünde bir yıldız yok.\nŞükür kavanozuna bir not bırak.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      // Twinkling Background Stars (Decorative)
                      ...List.generate(
                          50, (index) => _buildRandomStar(context)),

                      // Actual Entries as Constellation Nodes
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 100, bottom: 50),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 30,
                            runSpacing: 40,
                            children: _entries.map((entry) {
                              return GestureDetector(
                                onTap: () => _showEntryDetails(entry),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildGlowingStar(),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDate(entry.date),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildGlowingStar() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final shimmer =
            sin(_animController.value * 2 * pi + Random().nextDouble());
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGold.withOpacity(0.6 + (shimmer * 0.2)),
                blurRadius: 10 + (shimmer * 5),
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.star, size: 12, color: AppColors.accentGold),
          ),
        );
      },
    );
  }

  Widget _buildRandomStar(BuildContext context) {
    final random = Random();
    final size = random.nextDouble() * 3 + 1;
    return Positioned(
      left: random.nextDouble() * MediaQuery.of(context).size.width,
      top: random.nextDouble() * MediaQuery.of(context).size.height,
      child: Opacity(
        opacity: random.nextDouble() * 0.7 + 0.3,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
