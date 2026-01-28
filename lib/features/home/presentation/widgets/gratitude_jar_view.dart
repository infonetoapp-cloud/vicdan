import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

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
    _animController.forward().then((_) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text(
            "Nimet Kumbarası",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Playfair Display',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Bugün seni gülümseten bir nimeti seç veya yaz.",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // The "Card" being submitted
          SlideTransition(
            position: _slideAnimation,
            child: AnimatedOpacity(
              opacity: _isSubmitted ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Bugün neye şükrediyorsun?",
                          border: InputBorder.none,
                          prefixIcon:
                              Icon(Icons.edit, color: AppColors.softGreen),
                        ),
                        onSubmitted: _submitGratitude,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _commonBlessings.map((blessing) {
                          return ActionChip(
                            label: Text(blessing),
                            backgroundColor: Colors.white.withOpacity(0.5),
                            side: BorderSide.none,
                            onPressed: () {
                              _controller.text =
                                  blessing; // For visual confirmation
                              _submitGratitude(blessing);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          if (_isSubmitted)
            const Text(
              "Elhamdulillah\nNimetin Bereketlensin",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold),
            ),

          const SizedBox(height: 40),
          TextButton(
            onPressed: widget.onComplete,
            child: const Text("Kapat",
                style: TextStyle(color: AppColors.textLight)),
          )
        ],
      ),
    );
  }
}
