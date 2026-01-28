import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tree_painter.dart';
import '../../../../core/theme/app_colors.dart';

/// Interactive tree widget with animations
class TreeWidget extends StatefulWidget {
  const TreeWidget({
    super.key,
    required this.healthScore,
    this.onTap,
  });

  final int healthScore;
  final VoidCallback? onTap;

  @override
  State<TreeWidget> createState() => TreeWidgetState();
}

// Public state class so it can be accessed via GlobalKey
class TreeWidgetState extends State<TreeWidget> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _shakeController;
  late AnimationController _leafSwayController;
  late AnimationController _glowController;

  late Animation<double> _breathingAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _leafSwayAnimation;
  late Animation<double> _glowAnimation;

  final List<_FallingLeaf> _fallingLeaves = [];

  @override
  void initState() {
    super.initState();

    // Breathing animation (continuous)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _breathingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Shake animation (triggered)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.02), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.02, end: -0.02), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.02, end: 0.01), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.01, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOutQuart,
    ));

    // Leaf sway animation (continuous, slower)
    _leafSwayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _leafSwayAnimation =
        Tween<double>(begin: 0, end: 1).animate(_leafSwayController);

    // Glow animation (triggered)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
    ]).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _shakeController.dispose();
    _leafSwayController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void shake() {
    _shakeController.forward(from: 0);
    _spawnFallingLeaves();
  }

  void triggerGlow() {
    _glowController.forward(from: 0);
    _spawnFallingLeaves(count: 3);
  }

  void _spawnFallingLeaves({int count = 5}) {
    final random = math.Random();

    for (var i = 0; i < count; i++) {
      final leaf = _FallingLeaf(
        startX: 0.3 + random.nextDouble() * 0.4,
        startY: 0.2 + random.nextDouble() * 0.2,
        speed: 0.5 + random.nextDouble() * 0.5,
        wobble: random.nextDouble() * 2 - 1,
        delay: Duration(milliseconds: i * 100),
      );

      setState(() {
        _fallingLeaves.add(leaf);
      });

      // Remove leaf after animation
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _fallingLeaves.remove(leaf);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        shake();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingAnimation,
          _shakeAnimation,
          _leafSwayAnimation,
          _glowAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Tree
              CustomPaint(
                painter: TreePainter(
                  healthScore: widget.healthScore,
                  animationValue:
                      _breathingAnimation.value + _shakeAnimation.value,
                  leafSwayValue: _leafSwayAnimation.value,
                  glowIntensity: _glowAnimation.value,
                ),
                size: Size.infinite,
              ),

              // Falling leaves
              ..._fallingLeaves.map((leaf) => _FallingLeafWidget(leaf: leaf)),
            ],
          );
        },
      ),
    );
  }
}

/// Falling leaf data
class _FallingLeaf {
  _FallingLeaf({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.wobble,
    required this.delay,
  });

  final double startX;
  final double startY;
  final double speed;
  final double wobble;
  final Duration delay;
}

/// Falling leaf widget with animation
class _FallingLeafWidget extends StatefulWidget {
  const _FallingLeafWidget({required this.leaf});

  final _FallingLeaf leaf;

  @override
  State<_FallingLeafWidget> createState() => _FallingLeafWidgetState();
}

class _FallingLeafWidgetState extends State<_FallingLeafWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fallAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (2000 / widget.leaf.speed).round()),
    );

    _fallAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    Future.delayed(widget.leaf.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final x = widget.leaf.startX * size.width +
            math.sin(_fallAnimation.value * 4 * math.pi) *
                20 *
                widget.leaf.wobble;
        final y = widget.leaf.startY * size.height +
            _fallAnimation.value * size.height * 0.5;

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.leafLight,
                      AppColors.leafMedium,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(2),
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
