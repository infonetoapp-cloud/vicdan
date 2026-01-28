import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Animated sky background that changes based on time
class SkyGradientBackground extends StatelessWidget {
  const SkyGradientBackground({
    super.key,
    required this.child,
    this.timeProgress,
  });

  final Widget child;

  /// 0.0 = midnight, 0.5 = noon, 1.0 = midnight
  /// If null, uses current system time
  final double? timeProgress;

  double _getCurrentTimeProgress() {
    if (timeProgress != null) return timeProgress!;

    final now = DateTime.now();
    final totalMinutes = now.hour * 60 + now.minute;
    return totalMinutes / 1440; // 1440 = 24 * 60
  }

  List<Color> _getGradientColors(double progress) {
    final hour = (progress * 24).floor();
    return AppColors.getSkyGradient(hour);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getCurrentTimeProgress();
    final colors = _getGradientColors(progress);

    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

/// Interactive version with manual time control
class InteractiveSkyBackground extends StatefulWidget {
  const InteractiveSkyBackground({
    super.key,
    required this.child,
    this.showSlider = false,
  });

  final Widget child;
  final bool showSlider;

  @override
  State<InteractiveSkyBackground> createState() =>
      _InteractiveSkyBackgroundState();
}

class _InteractiveSkyBackgroundState extends State<InteractiveSkyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _manualProgress = 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Initialize with current time
    final now = DateTime.now();
    _manualProgress = (now.hour * 60 + now.minute) / 1440;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors() {
    final hour = (_manualProgress * 24).floor();
    return AppColors.getSkyGradient(hour);
  }

  String _getTimeString() {
    final totalMinutes = (_manualProgress * 1440).floor();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _getPeriodString() {
    final hour = (_manualProgress * 24).floor();
    if (hour >= 4 && hour < 6) return 'Fecir Vakti';
    if (hour >= 6 && hour < 10) return 'Sabah';
    if (hour >= 10 && hour < 14) return 'Öğle Vakti';
    if (hour >= 14 && hour < 17) return 'İkindi Vakti';
    if (hour >= 17 && hour < 20) return 'Akşam Vakti';
    return 'Yatsı Vakti';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getGradientColors(),
        ),
      ),
      child: Stack(
        children: [
          // Stars layer (visible at night)
          if (_manualProgress < 0.17 || _manualProgress > 0.83)
            const _StarsLayer(),

          // Main content
          widget.child,

          // Time slider (if enabled)
          if (widget.showSlider)
            Positioned(
              left: 20,
              right: 20,
              bottom: 100,
              child: _buildTimeSlider(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getTimeString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getPeriodString(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
            ),
            child: Slider(
              value: _manualProgress,
              onChanged: (value) {
                setState(() {
                  _manualProgress = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsLayer extends StatelessWidget {
  const _StarsLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _StarsPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Pseudo-random stars based on position
    for (var i = 0; i < 50; i++) {
      final x = (i * 17.3 + 23) % size.width;
      final y = (i * 31.7 + 11) % (size.height * 0.6);
      final radius = (i % 3 + 1) * 0.8;

      paint.color = Colors.white.withOpacity(0.3 + (i % 4) * 0.2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
