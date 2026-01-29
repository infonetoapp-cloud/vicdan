import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/social/data/models/soul_signal.dart';

/// CustomPainter for the VİCDAN Tree
/// Renders trunk, branches, and leaf clusters with health-based states
class TreePainter extends CustomPainter {
  TreePainter({
    required this.healthScore,
    required this.animationValue,
    this.leafSwayValue = 0.0,
    this.glowIntensity = 0.0,
    this.activeSignals = const [],
  });

  /// Tree health score (0-100)
  final int healthScore;

  /// Main animation value (0-1) for breathing/shake
  final double animationValue;

  /// Leaf sway animation value (0-1)
  final double leafSwayValue;

  /// Glow effect intensity (0-1) for task completion
  final double glowIntensity;

  /// Active social signals (prayers)
  final List<SoulSignal> activeSignals;

  @override
  void paint(Canvas canvas, Size size) {
    // ... existing implementation remains same until _drawSocialRoots ...
    final centerX = size.width / 2;
    final groundY = size.height * 0.85;

    // Apply subtle rotation for breathing/shake
    final swayAngle = math.sin(animationValue * 2 * math.pi) * 0.02;

    canvas.save();
    canvas.translate(centerX, groundY);
    canvas.rotate(swayAngle);
    canvas.translate(-centerX, -groundY);

    // Draw glow effect if active
    if (glowIntensity > 0) {
      _drawGlow(canvas, size, centerX, groundY);
    }

    // Draw trunk and roots
    _drawTrunk(canvas, centerX, groundY);

    // Draw branches based on health
    if (healthScore > 20) {
      _drawBranches(canvas, centerX, groundY);
    }

    // Draw leaf clusters
    _drawLeafClusters(canvas, centerX, groundY);

    // Draw flowers if health > 80
    if (healthScore > 80) {
      _drawFlowers(canvas, centerX, groundY);
    }

    canvas.restore();
  }

  // ... _drawGlow remains same ...
  void _drawGlow(Canvas canvas, Size size, double centerX, double groundY) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.sage.withOpacity(0.4 * glowIntensity),
          AppColors.sage.withOpacity(0.1 * glowIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, groundY - 120),
        radius: 150,
      ));

    canvas.drawCircle(
      Offset(centerX, groundY - 120),
      150,
      glowPaint,
    );
  }

  // ... _drawTrunk remains same until _drawSocialRoots call ...
  void _drawTrunk(Canvas canvas, double centerX, double groundY) {
    final trunkWidth = 20.0 + (healthScore / 100) * 10;
    final trunkHeight = 80.0 + (healthScore / 100) * 20;

    final trunkPath = Path();

    // Trunk base (wider at bottom)
    trunkPath.moveTo(centerX - trunkWidth / 2 - 4, groundY);
    trunkPath.quadraticBezierTo(
      centerX - trunkWidth / 2,
      groundY - trunkHeight / 2,
      centerX - trunkWidth / 3,
      groundY - trunkHeight,
    );
    trunkPath.lineTo(centerX + trunkWidth / 3, groundY - trunkHeight);
    trunkPath.quadraticBezierTo(
      centerX + trunkWidth / 2,
      groundY - trunkHeight / 2,
      centerX + trunkWidth / 2 + 4,
      groundY,
    );
    trunkPath.close();

    // Trunk gradient
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.trunk,
          AppColors.trunkLight,
          AppColors.trunk,
        ],
      ).createShader(Rect.fromLTWH(
        centerX - trunkWidth,
        groundY - trunkHeight,
        trunkWidth * 2,
        trunkHeight,
      ));

    canvas.drawPath(trunkPath, trunkPaint);

    // Trunk shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(
      trunkPath.shift(const Offset(3, 0)),
      shadowPaint,
    );

    // Ground/root shadow
    final groundShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, groundY + 5),
        width: trunkWidth * 2,
        height: 15,
      ),
      groundShadowPaint,
    );

    // Social Roots (Görünmez Bağlar) - REAL TIME DATA
    _drawSocialRoots(canvas, centerX, groundY, trunkWidth);
  }

  void _drawSocialRoots(
      Canvas canvas, double centerX, double groundY, double trunkWidth) {
    if (activeSignals.isEmpty) {
      // Draw one subtle pulse just to show system is alive
      _drawSingleRootNode(canvas, centerX, groundY, trunkWidth,
          Offset(centerX, groundY + 50), 0.2);
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    // Root base structure (static)
    final rootPaint = Paint()
      ..color = AppColors.accentGold.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rootPath = Path();
    rootPath.moveTo(centerX - trunkWidth / 3, groundY);
    rootPath.quadraticBezierTo(centerX - trunkWidth, groundY + 40,
        centerX - trunkWidth * 2, groundY + 80);

    rootPath.moveTo(centerX + trunkWidth / 3, groundY);
    rootPath.quadraticBezierTo(centerX + trunkWidth, groundY + 40,
        centerX + trunkWidth * 2, groundY + 80);

    rootPath.moveTo(centerX, groundY + 5);
    rootPath.lineTo(centerX, groundY + 60);

    canvas.drawPath(rootPath, rootPaint);

    // Draw active signals as glowing nodes
    for (int i = 0; i < activeSignals.length; i++) {
      final signal = activeSignals[i];

      // Deterministic position based on signal ID hash
      final hash = signal.id.hashCode;
      final randomX = (hash % 100) / 50.0 - 1.0; // -1 to 1
      final randomY = (hash % 50) / 50.0; // 0 to 1

      final offsetX = centerX + (randomX * trunkWidth * 3);
      final offsetY = groundY + 40 + (randomY * 60);

      // Pulse based on time + index offset
      final pulse = (math.sin((now / 1000) + i) + 1) / 2;

      _drawSingleRootNode(canvas, centerX, groundY, trunkWidth,
          Offset(offsetX, offsetY), pulse);
    }
  }

  void _drawSingleRootNode(Canvas canvas, double centerX, double groundY,
      double trunkWidth, Offset pos, double pulse) {
    final nodePaint = Paint()
      ..color = AppColors.accentGold.withOpacity(0.6 * pulse)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 3 + pulse * 2, nodePaint);

    // Glow halo
    canvas.drawCircle(pos, 8 + pulse * 4,
        Paint()..color = AppColors.accentGold.withOpacity(0.1 * pulse));

    // Connection line to center (very faint)
    final linePaint = Paint()
      ..color = AppColors.accentGold.withOpacity(0.05 * pulse)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(centerX, groundY + 10), pos, linePaint);
  }

  void _drawBranches(Canvas canvas, double centerX, double groundY) {
    final branchPaint = Paint()
      ..color = AppColors.trunk
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final trunkTop = groundY - 90;

    // Left branch
    if (healthScore > 40) {
      final leftBranch = Path()
        ..moveTo(centerX - 5, trunkTop + 20)
        ..quadraticBezierTo(
          centerX - 30,
          trunkTop,
          centerX - 45,
          trunkTop - 20,
        );
      canvas.drawPath(leftBranch, branchPaint);
    }

    // Right branch
    if (healthScore > 40) {
      final rightBranch = Path()
        ..moveTo(centerX + 5, trunkTop + 20)
        ..quadraticBezierTo(
          centerX + 30,
          trunkTop,
          centerX + 45,
          trunkTop - 20,
        );
      canvas.drawPath(rightBranch, branchPaint);
    }

    // Top branch
    if (healthScore > 60) {
      final topBranch = Path()
        ..moveTo(centerX, trunkTop)
        ..quadraticBezierTo(
          centerX + 5,
          trunkTop - 20,
          centerX,
          trunkTop - 40,
        );
      canvas.drawPath(topBranch, branchPaint);
    }
  }

  void _drawLeafClusters(Canvas canvas, double centerX, double groundY) {
    final trunkTop = groundY - 90;

    // Calculate leaf count based on health
    final leafOpacity = (healthScore / 100).clamp(0.3, 1.0);

    // Get leaf colors based on health
    Color primaryLeafColor;
    Color secondaryLeafColor;

    if (healthScore < 21) {
      // Bare - gray/brown
      primaryLeafColor = Colors.grey.shade600;
      secondaryLeafColor = Colors.grey.shade700;
    } else if (healthScore < 41) {
      // Budding - yellow-green
      primaryLeafColor = const Color(0xFFCDDC39);
      secondaryLeafColor = const Color(0xFFAFB42B);
    } else {
      // Healthy - vibrant green
      primaryLeafColor = AppColors.leafMedium;
      secondaryLeafColor = AppColors.leafDark;
    }

    // Sway offset
    final swayOffset = math.sin(leafSwayValue * 2 * math.pi) * 3;

    // Draw multiple leaf clusters
    _drawLeafCluster(
      canvas,
      Offset(centerX + swayOffset, trunkTop - 70),
      60 + healthScore * 0.4,
      primaryLeafColor.withOpacity(leafOpacity),
      secondaryLeafColor.withOpacity(leafOpacity),
    );

    _drawLeafCluster(
      canvas,
      Offset(centerX - 35 + swayOffset * 0.8, trunkTop - 30),
      50 + healthScore * 0.3,
      secondaryLeafColor.withOpacity(leafOpacity),
      AppColors.leafDeep.withOpacity(leafOpacity),
    );

    _drawLeafCluster(
      canvas,
      Offset(centerX + 35 + swayOffset * 0.8, trunkTop - 30),
      50 + healthScore * 0.3,
      primaryLeafColor.withOpacity(leafOpacity),
      secondaryLeafColor.withOpacity(leafOpacity),
    );

    if (healthScore > 60) {
      _drawLeafCluster(
        canvas,
        Offset(centerX + swayOffset * 0.6, trunkTop - 100),
        45 + healthScore * 0.2,
        AppColors.leafLight.withOpacity(leafOpacity),
        primaryLeafColor.withOpacity(leafOpacity),
      );
    }
  }

  void _drawLeafCluster(
    Canvas canvas,
    Offset center,
    double radius,
    Color color1,
    Color color2,
  ) {
    final clusterPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [color1, color2],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, clusterPaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(
      center + Offset(-radius * 0.2, -radius * 0.2),
      radius * 0.4,
      highlightPaint,
    );
  }

  void _drawFlowers(Canvas canvas, double centerX, double groundY) {
    final trunkTop = groundY - 90;
    final flowerPaint = Paint()..color = AppColors.cherryBlossom;

    // Scatter flowers on leaf clusters
    final flowerPositions = [
      Offset(centerX - 40, trunkTop - 60),
      Offset(centerX + 35, trunkTop - 50),
      Offset(centerX - 15, trunkTop - 90),
      Offset(centerX + 20, trunkTop - 85),
      Offset(centerX, trunkTop - 110),
    ];

    for (final pos in flowerPositions) {
      // Flower petals
      for (var i = 0; i < 5; i++) {
        final angle = (i * 72) * math.pi / 180;
        final petalCenter = Offset(
          pos.dx + math.cos(angle) * 5,
          pos.dy + math.sin(angle) * 5,
        );
        canvas.drawCircle(petalCenter, 4, flowerPaint);
      }

      // Flower center
      canvas.drawCircle(
        pos,
        3,
        Paint()..color = AppColors.goldenHour,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.healthScore != healthScore ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.leafSwayValue != leafSwayValue ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.activeSignals.length !=
            activeSignals.length; // Simplistic check (length)
  }
}
