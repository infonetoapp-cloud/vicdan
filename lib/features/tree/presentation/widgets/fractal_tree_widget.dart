import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'fractal_tree_painter.dart';

/// Interactive fractal tree widget with physics-based animations
///
/// Features:
/// - Continuous breathing animation
/// - Wind simulation with accelerometer input
/// - Shake detection for leaf fall
/// - Task completion glow effect
class FractalTreeWidget extends StatefulWidget {
  const FractalTreeWidget({
    super.key,
    required this.healthScore,
    this.onTap,
  });

  final int healthScore;
  final VoidCallback? onTap;

  @override
  State<FractalTreeWidget> createState() => FractalTreeWidgetState();
}

class FractalTreeWidgetState extends State<FractalTreeWidget>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _breathController;
  late AnimationController _windController;
  late AnimationController _glowController;
  late AnimationController _shakeController;

  // Animations
  late Animation<double> _breathAnimation;
  late Animation<double> _windAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shakeAnimation;

  // Falling leaves
  final List<_FallingLeaf> _fallingLeaves = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Breathing - slow, continuous, organic
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _breathAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    // Wind - continuous with varying intensity
    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _windAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _windController,
        curve: Curves.linear,
      ),
    );

    // Glow - triggered on task completion
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

    // Shake - triggered on tap
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: -0.025), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.025, end: 0.015), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.015, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _breathController.dispose();
    _windController.dispose();
    _glowController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Trigger glow effect (call when task is completed)
  void triggerGlow() {
    _glowController.forward(from: 0);
    HapticFeedback.mediumImpact();
    _spawnLeaves(count: 3);
  }

  /// Trigger shake effect
  void shake() {
    _shakeController.forward(from: 0);
    HapticFeedback.lightImpact();
    _spawnLeaves(count: 5);
  }

  void _spawnLeaves({int count = 5}) {
    final random = math.Random();

    for (var i = 0; i < count; i++) {
      final leaf = _FallingLeaf(
        startX: 0.35 + random.nextDouble() * 0.3,
        startY: 0.2 + random.nextDouble() * 0.25,
        speed: 0.4 + random.nextDouble() * 0.4,
        wobbleFreq: 2 + random.nextDouble() * 2,
        rotationSpeed: 1 + random.nextDouble() * 2,
        delay: Duration(milliseconds: i * 80),
        size: 8 + random.nextDouble() * 6,
      );

      setState(() => _fallingLeaves.add(leaf));

      // Auto-remove after animation
      Future.delayed(const Duration(milliseconds: 2800), () {
        if (mounted) {
          setState(() => _fallingLeaves.remove(leaf));
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
          _breathAnimation,
          _windAnimation,
          _glowAnimation,
          _shakeAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Fractal Tree
              Transform.rotate(
                angle: _shakeAnimation.value,
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  painter: FractalTreePainter(
                    healthScore: widget.healthScore,
                    windPhase: _windAnimation.value,
                    breathPhase: _breathAnimation.value,
                    glowIntensity: _glowAnimation.value,
                  ),
                  size: Size.infinite,
                ),
              ),

              // Falling leaves overlay
              ..._fallingLeaves.map((leaf) => _FallingLeafWidget(
                    leaf: leaf,
                    healthScore: widget.healthScore,
                  )),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FALLING LEAF SYSTEM
// ═══════════════════════════════════════════════════════════

class _FallingLeaf {
  _FallingLeaf({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.wobbleFreq,
    required this.rotationSpeed,
    required this.delay,
    required this.size,
  });

  final double startX;
  final double startY;
  final double speed;
  final double wobbleFreq;
  final double rotationSpeed;
  final Duration delay;
  final double size;
}

class _FallingLeafWidget extends StatefulWidget {
  const _FallingLeafWidget({
    required this.leaf,
    required this.healthScore,
  });

  final _FallingLeaf leaf;
  final int healthScore;

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
      duration: Duration(milliseconds: (2200 / widget.leaf.speed).round()),
    );

    _fallAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: widget.leaf.rotationSpeed * 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    Future.delayed(widget.leaf.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getLeafColor() {
    if (widget.healthScore < 41) {
      return const Color(0xFFD4E157); // Yellow-green
    } else if (widget.healthScore < 81) {
      return const Color(0xFF6B9362); // Green
    } else {
      return const Color(0xFF7CB342); // Vibrant green
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final wobble = math.sin(
              _fallAnimation.value * widget.leaf.wobbleFreq * math.pi,
            ) *
            25;

        final x = widget.leaf.startX * size.width + wobble;
        final y = widget.leaf.startY * size.height +
            _fallAnimation.value * size.height * 0.45;

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Container(
                width: widget.leaf.size,
                height: widget.leaf.size,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _getLeafColor(),
                      _getLeafColor().withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.leaf.size * 0.8),
                    topRight: Radius.circular(widget.leaf.size * 0.15),
                    bottomLeft: Radius.circular(widget.leaf.size * 0.15),
                    bottomRight: Radius.circular(widget.leaf.size * 0.8),
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
