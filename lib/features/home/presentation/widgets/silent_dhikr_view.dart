import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SilentDhikrView extends StatefulWidget {
  final VoidCallback onComplete;
  const SilentDhikrView({super.key, required this.onComplete});

  @override
  State<SilentDhikrView> createState() => _SilentDhikrViewState();
}

class _SilentDhikrViewState extends State<SilentDhikrView>
    with TickerProviderStateMixin {
  int _count = 0;
  final List<_Ripple> _ripples = [];
  late AnimationController _pulseController;

  // Dhikr words to cycle through or pick one
  final String _dhikr = "Elhamdulillah";

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap(TapUpDetails details) {
    setState(() {
      _count++;
      // Add a ripple at the touch position
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );

      final ripple = _Ripple(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        controller: controller,
        position: details.localPosition,
      );

      _ripples.add(ripple);

      controller.forward().then((_) {
        _ripples.removeWhere((r) => r.id == ripple.id);
        controller.dispose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTap,
      child: Container(
        color: Colors.transparent, // Capture taps everywhere
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripples
            ..._ripples.map((ripple) => AnimatedBuilder(
                  animation: ripple.controller,
                  builder: (context, child) {
                    final t = ripple.controller.value;
                    return Positioned(
                      left: ripple.position.dx - (100 * t),
                      top: ripple.position.dy - (100 * t),
                      child: Container(
                        width: 200 * t,
                        height: 200 * t,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                AppColors.accentGold.withOpacity((1 - t) * 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                )),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.05)
                      .animate(_pulseController),
                  child: Text(
                    _dhikr,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "$_count",
                  style: TextStyle(
                    fontSize: 48,
                    color: AppColors.accentGold.withOpacity(0.8),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Ekrana her dokunuş bir şükürdür.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            // Close button at the bottom
            Positioned(
              bottom: 32,
              child: TextButton(
                onPressed: widget.onComplete,
                child: const Text(
                  "Huzura Erdim",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ripple {
  final String id;
  final AnimationController controller;
  final Offset position;

  _Ripple({required this.id, required this.controller, required this.position});
}
