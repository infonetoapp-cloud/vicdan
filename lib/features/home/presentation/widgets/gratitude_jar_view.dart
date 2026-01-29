import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../journal/data/journal_repository.dart';
import '../../../journal/presentation/screens/soul_journal_screen.dart';

class GratitudeJarView extends StatefulWidget {
  final VoidCallback onComplete;
  const GratitudeJarView({super.key, required this.onComplete});

  @override
  State<GratitudeJarView> createState() => _GratitudeJarViewState();
}

class _GratitudeJarViewState extends State<GratitudeJarView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<String> _commonBlessings = [
    "Ailem ❤️",
    "Sağlığım 💪",
    "Huzurum 🕊️",
    "Rızkım 🍞",
    "İmanım 🕌",
    "Arkadaşlarım 🤝",
    "Bugünkü Güneş ☀️",
    "Aldığım Nefes 🌬️",
  ];

  bool _isSubmitted = false;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2), // Slide down off screen (into the "jar")
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submitGratitude(String text) {
    if (text.isEmpty) return;

    setState(() {
      _isSubmitted = true;
    });

    // Animate item dropping into "jar"
    _animController.forward().then((_) async {
      // Save to repository
      await JournalRepository().addEntry(text);

      if (!mounted) return;
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bu nimetin şükrü kaydedildi. Elhamdulillah."),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );

      // Delay closing to let user feel the satisfaction
      Future.delayed(const Duration(milliseconds: 1000), () {
        widget.onComplete();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        // No fixed height, let content expand
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Nimet Kumbarası",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Bugün seni gülümseten bir nimeti seç veya yaz. Kumbaranda biriksin.",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // KEY FEATURE: The "Jar" Animation Area
            // We use the animated controller to 'drop' the card into a virtual jar bottom
            SlideTransition(
              position: _slideAnimation,
              child: AnimatedOpacity(
                opacity: _isSubmitted ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Input Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Bugün neye şükrediyorsun...",
                              border: InputBorder.none,
                              icon: Icon(Icons.edit_note,
                                  color: AppColors.softGreen),
                            ),
                            onSubmitted: _submitGratitude,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Modern Chips
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: _commonBlessings.map((blessing) {
                            return GestureDetector(
                              onTap: () {
                                _controller.text = blessing; // Visual
                                _submitGratitude(blessing);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                  border: Border.all(
                                      color:
                                          AppColors.softGreen.withOpacity(0.2)),
                                ),
                                child: Text(
                                  blessing,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_isSubmitted) ...[
              const Icon(Icons.check_circle,
                  size: 48, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              const Text(
                "Kumbaraya Atıldı!\nElhamdulillah.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold),
              ),
            ],

            const SizedBox(height: 20),

            // "See Drawer" Button
            if (!_isSubmitted)
              TextButton.icon(
                onPressed: () {
                  if (mounted) Navigator.of(context).pop(); // Close sheet first
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SoulJournalScreen()),
                  );
                },
                icon: const Icon(Icons.inventory_2_outlined,
                    size: 18, color: AppColors.textLight),
                label: const Text("Kumbaramı Gör",
                    style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600)),
              ),

            const SizedBox(height: 50), // Extra padding for bottom safety
          ],
        ),
      ),
    );
  }
}
