import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A single branch segment in the fractal tree
class Branch {
  Branch({
    required this.start,
    required this.end,
    required this.thickness,
    required this.depth,
    required this.angle,
    this.windOffset = 0.0,
  });

  final Offset start;
  final Offset end;
  final double thickness;
  final int depth;
  final double angle;
  double windOffset;

  /// Length of the branch
  double get length => (end - start).distance;

  /// End point with wind applied
  Offset endWithWind(double windStrength, double windPhase) {
    final windAngle =
        math.sin(windPhase + depth * 0.5) * windStrength * (depth / 3);
    final cosA = math.cos(angle + windAngle);
    final sinA = math.sin(angle + windAngle);
    return Offset(
      start.dx + length * sinA,
      start.dy - length * cosA,
    );
  }
}

/// Leaf cluster data for rendering
class LeafCluster {
  LeafCluster({
    required this.position,
    required this.radius,
    required this.depth,
    required this.branchAngle,
  });

  final Offset position;
  final double radius;
  final int depth;
  final double branchAngle;
}

/// Vicdan Fractal Tree - L-System inspired generative tree
///
/// Growth is based on health score:
/// - 0-20: Bare trunk with few buds
/// - 21-40: Seedling with small branches
/// - 41-60: Young tree with moderate branching
/// - 61-80: Mature tree with full canopy
/// - 81-100: Blooming elder tree with flowers
class FractalTreePainter extends CustomPainter {
  FractalTreePainter({
    required this.healthScore,
    required this.windPhase,
    required this.breathPhase,
    required this.glowIntensity,
    this.showDebugLines = false,
  }) {
    _generateTree();
  }

  final int healthScore;
  final double windPhase;
  final double breathPhase;
  final double glowIntensity;
  final bool showDebugLines;

  final List<Branch> _branches = [];
  final List<LeafCluster> _leafClusters = [];
  final math.Random _random = math.Random(42); // Fixed seed for consistency

  // ═══════════════════════════════════════════════════════════
  // GROWTH PARAMETERS based on health
  // ═══════════════════════════════════════════════════════════

  int get _maxDepth {
    if (healthScore < 21) return 2;
    if (healthScore < 41) return 3;
    if (healthScore < 61) return 4;
    if (healthScore < 81) return 5;
    return 6;
  }

  double get _branchLengthMultiplier {
    return 0.65 + (healthScore / 100) * 0.15; // 0.65 - 0.80
  }

  double get _branchingAngle {
    // More organic angles for healthier trees
    return (25 + (healthScore / 100) * 15) * math.pi / 180; // 25-40 degrees
  }

  double get _windStrength {
    return 0.05 + math.sin(breathPhase * 2) * 0.02;
  }

  // ═══════════════════════════════════════════════════════════
  // L-SYSTEM TREE GENERATION
  // ═══════════════════════════════════════════════════════════

  void _generateTree() {
    _branches.clear();
    _leafClusters.clear();

    // Trunk parameters
    const trunkLength = 80.0;
    const trunkThickness = 12.0;
    const startPoint = Offset(0, 0); // Will be translated in paint

    // Generate trunk
    final trunk = Branch(
      start: startPoint,
      end: Offset(0, -trunkLength),
      thickness: trunkThickness,
      depth: 0,
      angle: 0,
    );
    _branches.add(trunk);

    // Recursively generate branches
    _generateBranches(trunk, 1);
  }

  void _generateBranches(Branch parent, int depth) {
    if (depth > _maxDepth) return;

    final lengthFactor = _branchLengthMultiplier - (depth * 0.05);
    final newLength = parent.length * lengthFactor;
    final newThickness = parent.thickness * 0.7;

    // Asymmetric branching for organic look
    final leftAngle =
        parent.angle - _branchingAngle * (0.8 + _random.nextDouble() * 0.4);
    final rightAngle =
        parent.angle + _branchingAngle * (0.8 + _random.nextDouble() * 0.4);

    // Left branch
    final leftEnd = Offset(
      parent.end.dx + newLength * math.sin(leftAngle),
      parent.end.dy - newLength * math.cos(leftAngle),
    );
    final leftBranch = Branch(
      start: parent.end,
      end: leftEnd,
      thickness: newThickness,
      depth: depth,
      angle: leftAngle,
    );
    _branches.add(leftBranch);

    // Right branch
    final rightEnd = Offset(
      parent.end.dx + newLength * math.sin(rightAngle),
      parent.end.dy - newLength * math.cos(rightAngle),
    );
    final rightBranch = Branch(
      start: parent.end,
      end: rightEnd,
      thickness: newThickness,
      depth: depth,
      angle: rightAngle,
    );
    _branches.add(rightBranch);

    // Sometimes add a center branch for more fullness
    if (healthScore > 50 &&
        depth < _maxDepth - 1 &&
        _random.nextDouble() > 0.5) {
      final centerAngle = parent.angle + (_random.nextDouble() - 0.5) * 0.3;
      final centerEnd = Offset(
        parent.end.dx + newLength * 0.8 * math.sin(centerAngle),
        parent.end.dy - newLength * 0.8 * math.cos(centerAngle),
      );
      final centerBranch = Branch(
        start: parent.end,
        end: centerEnd,
        thickness: newThickness * 0.8,
        depth: depth,
        angle: centerAngle,
      );
      _branches.add(centerBranch);
      _generateBranches(centerBranch, depth + 1);
    }

    // Recurse
    _generateBranches(leftBranch, depth + 1);
    _generateBranches(rightBranch, depth + 1);

    // Add leaf clusters at terminal branches
    if (depth >= _maxDepth - 1 && healthScore > 20) {
      _addLeafCluster(leftBranch);
      _addLeafCluster(rightBranch);
    }
  }

  void _addLeafCluster(Branch branch) {
    final clusterRadius = 15.0 + (healthScore / 100) * 20;
    _leafClusters.add(LeafCluster(
      position: branch.end,
      radius: clusterRadius * (0.8 + _random.nextDouble() * 0.4),
      depth: branch.depth,
      branchAngle: branch.angle,
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // RENDERING
  // ═══════════════════════════════════════════════════════════

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.85;

    canvas.save();
    canvas.translate(centerX, groundY);

    // Apply gentle breathing sway to whole tree
    final breathSway = math.sin(breathPhase * math.pi * 2) * 0.015;
    canvas.rotate(breathSway);

    // Draw glow effect if active
    if (glowIntensity > 0) {
      _drawTreeGlow(canvas);
    }

    // Draw ground shadow
    _drawGroundShadow(canvas);

    // Draw branches (back to front by depth)
    _drawBranches(canvas);

    // Draw leaf clusters
    _drawLeafClusters(canvas);

    // Draw flowers if health > 80
    if (healthScore > 80) {
      _drawFlowers(canvas);
    }

    canvas.restore();
  }

  void _drawGroundShadow(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, 8),
        width: 50 + healthScore * 0.3,
        height: 12,
      ),
      shadowPaint,
    );
  }

  void _drawTreeGlow(Canvas canvas) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6B9362).withOpacity(0.5 * glowIntensity),
          const Color(0xFF6B9362).withOpacity(0.15 * glowIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
          Rect.fromCircle(center: const Offset(0, -80), radius: 120));

    canvas.drawCircle(const Offset(0, -80), 120, glowPaint);
  }

  void _drawBranches(Canvas canvas) {
    // Sort by depth for proper layering
    final sortedBranches = List<Branch>.from(_branches)
      ..sort((a, b) => a.depth.compareTo(b.depth));

    for (final branch in sortedBranches) {
      final endPoint = branch.endWithWind(_windStrength, windPhase);

      // Branch gradient from dark to light
      final branchPaint = Paint()
        ..strokeWidth = branch.thickness
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Color based on depth
      if (branch.depth == 0) {
        // Trunk - darker brown
        branchPaint.shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF3D2817),
            const Color(0xFF5C4033),
          ],
        ).createShader(Rect.fromPoints(branch.start, endPoint));
      } else {
        // Branches - gradient to lighter
        final depthFactor = branch.depth / _maxDepth;
        branchPaint.color = Color.lerp(
          const Color(0xFF5C4033),
          const Color(0xFF8B7355),
          depthFactor,
        )!;
      }

      // Draw with path for smooth curves
      final path = Path()
        ..moveTo(branch.start.dx, branch.start.dy)
        ..lineTo(endPoint.dx, endPoint.dy);

      canvas.drawPath(path, branchPaint);
    }
  }

  void _drawLeafClusters(Canvas canvas) {
    for (final cluster in _leafClusters) {
      // Wind-affected position
      final windOffset =
          math.sin(windPhase + cluster.depth * 0.7) * 5 * _windStrength * 10;
      final position =
          Offset(cluster.position.dx + windOffset, cluster.position.dy);

      // Leaf color gradient
      final leafPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            _getLeafColor(cluster.depth, light: true),
            _getLeafColor(cluster.depth, light: false),
          ],
        ).createShader(
            Rect.fromCircle(center: position, radius: cluster.radius));

      // Main leaf cluster
      canvas.drawCircle(position, cluster.radius, leafPaint);

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        position + Offset(-cluster.radius * 0.2, -cluster.radius * 0.25),
        cluster.radius * 0.4,
        highlightPaint,
      );

      // Subtle shadow for depth
      if (cluster.depth < _maxDepth) {
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(
          position + const Offset(3, 4),
          cluster.radius * 0.9,
          shadowPaint,
        );
      }
    }
  }

  Color _getLeafColor(int depth, {required bool light}) {
    // Health-based color
    if (healthScore < 21) {
      // Bare - gray
      return light ? const Color(0xFF8B8B83) : const Color(0xFF6B6B63);
    } else if (healthScore < 41) {
      // Budding - yellow-green
      return light ? const Color(0xFFD4E157) : const Color(0xFFAFB42B);
    } else if (healthScore < 61) {
      // Young - light green
      return light ? const Color(0xFF8BC34A) : const Color(0xFF689F38);
    } else if (healthScore < 81) {
      // Mature - rich green
      return light ? const Color(0xFF6B9362) : const Color(0xFF4A7C4E);
    } else {
      // Elder - deep vibrant green
      return light ? const Color(0xFF7CB342) : const Color(0xFF558B2F);
    }
  }

  void _drawFlowers(Canvas canvas) {
    final flowerPaint = Paint()..color = const Color(0xFFFFB7C5);
    final centerPaint = Paint()..color = const Color(0xFFFFD700);

    // Add flowers at some leaf cluster positions
    for (var i = 0; i < _leafClusters.length; i += 3) {
      final cluster = _leafClusters[i];
      final windOffset = math.sin(windPhase + cluster.depth * 0.7) * 3;

      final flowerPos = Offset(
        cluster.position.dx + windOffset + _random.nextDouble() * 10 - 5,
        cluster.position.dy - cluster.radius * 0.5,
      );

      // 5 petals
      for (var p = 0; p < 5; p++) {
        final petalAngle = (p * 72) * math.pi / 180;
        final petalPos = Offset(
          flowerPos.dx + math.cos(petalAngle) * 4,
          flowerPos.dy + math.sin(petalAngle) * 4,
        );
        canvas.drawCircle(petalPos, 3.5, flowerPaint);
      }

      // Center
      canvas.drawCircle(flowerPos, 2.5, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FractalTreePainter oldDelegate) {
    return oldDelegate.healthScore != healthScore ||
        oldDelegate.windPhase != windPhase ||
        oldDelegate.breathPhase != breathPhase ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
