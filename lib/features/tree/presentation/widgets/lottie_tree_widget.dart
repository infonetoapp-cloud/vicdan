import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

/// Premium Lottie-based tree widget with progress control
///
/// The animation progress is controlled by health score:
/// - 0-100 maps to 0-100% animation progress
/// - Allows for smooth growth visualization
class LottieTreeWidget extends StatefulWidget {
  const LottieTreeWidget({
    super.key,
    required this.healthScore,
    this.onTap,
  });

  final int healthScore;
  final VoidCallback? onTap;

  @override
  State<LottieTreeWidget> createState() => LottieTreeWidgetState();
}

class LottieTreeWidgetState extends State<LottieTreeWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Breathing animation controllers
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller - progress based on health
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // Set initial progress based on health
    _updateProgress();

    // Breathing (Life) Controller
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine, // Smooth sine wave breathing
      ),
    );

    // Glow effect controller
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
    ]).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOut,
    ));
  }

  void _updateProgress() {
    // Map health score (0-100) to animation progress (0.15-1.0)
    // 0.15 ensures the 'seedling' is always visible even at 0 health
    const minProgress = 0.15;
    final normalizedHealth = widget.healthScore / 100.0; // 0.0 to 1.0

    // Lerp from 0.15 to 1.0 based on health
    final progress = minProgress + (normalizedHealth * (1.0 - minProgress));

    _controller.value = progress.clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(LottieTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.healthScore != widget.healthScore) {
      // Recalculate with min progress logic
      const minProgress = 0.15;
      final normalizedHealth = widget.healthScore / 100.0;
      final targetProgress =
          minProgress + (normalizedHealth * (1.0 - minProgress));

      // Animate to new progress
      _controller.animateTo(
        targetProgress.clamp(0.0, 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Trigger glow effect (on task completion)
  void triggerGlow() {
    _glowController.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  /// Shake effect
  void shake() {
    HapticFeedback.lightImpact();
    triggerGlow();
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        shake();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _breathingAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect behind tree
              if (_glowAnimation.value > 0)
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B9362).withOpacity(
                          0.6 * _glowAnimation.value,
                        ),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),

              // Lottie animation with Breathing Effect
              Transform.scale(
                scale: _breathingAnimation.value,
                child: Lottie.asset(
                  'assets/lottie/tree_growth.json',
                  controller: _controller,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    // Update the controller duration to match animation
                    _controller.duration = composition.duration;
                    _updateProgress();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
