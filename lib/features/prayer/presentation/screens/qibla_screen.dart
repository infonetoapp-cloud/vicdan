import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final _locationService = LocationService();
  StreamSubscription<CompassEvent>? _subscription;
  double? _heading;
  double? _qiblaBearing;
  bool _wasAligned = false;
  bool _loading = true;
  String _status = 'Kalibrasyon yapılıyor';

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initQibla() async {
    try {
      final position = await _locationService.determinePosition();
      final bearing = _calculateBearing(
        position.latitude,
        position.longitude,
        21.4225,
        39.8262,
      );
      _qiblaBearing = bearing;
      _subscription = FlutterCompass.events?.listen((event) {
        if (!mounted) return;
        final heading = event.heading;
        final aligned = heading != null && _isAligned(heading);
        if (aligned && !_wasAligned) {
          HapticFeedback.lightImpact();
        }
        setState(() {
          _heading = heading;
          _wasAligned = aligned;
          _loading = false;
          _status = heading == null
              ? 'Telefonu sekiz çiz'
              : (aligned ? 'Kıble bulundu' : 'Kıbleye yaklaşıyorsun');
        });
      });
      if (FlutterCompass.events == null) {
        setState(() {
          _loading = false;
          _status = 'Cihaz pusula desteklemiyor';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _status = 'Konum alınamadı';
        });
      }
    }
  }

  double _calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = _degToRad(lat1);
    final phi2 = _degToRad(lat2);
    final delta = _degToRad(lon2 - lon1);
    final y = sin(delta) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(delta);
    final theta = atan2(y, x);
    final bearing = (_radToDeg(theta) + 360) % 360;
    return bearing;
  }

  double _degToRad(double deg) => deg * (pi / 180);
  double _radToDeg(double rad) => rad * (180 / pi);
  double _normalizeAngle(double angle) => (angle + 360) % 360;

  bool _isAligned(double heading) {
    final bearing = _qiblaBearing ?? 0;
    final diff = (_normalizeAngle(bearing - heading)).abs();
    final delta = diff > 180 ? 360 - diff : diff;
    return delta <= 6;
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading ?? 0;
    final bearing = _qiblaBearing ?? 0;
    final rotation = _degToRad(bearing - heading);
    final aligned = !_loading && _heading != null && _isAligned(heading);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.skyMorning,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 300,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.06),
                                    border: Border.all(
                                      color: aligned
                                          ? AppColors.goldenHour
                                          : AppColors.glassBorder,
                                      width: aligned ? 2 : 1,
                                    ),
                                    boxShadow: aligned
                                        ? [
                                            BoxShadow(
                                              color: AppColors.goldenHour
                                                  .withOpacity(0.35),
                                              blurRadius: 24,
                                              spreadRadius: 4,
                                            ),
                                          ]
                                        : [],
                                  ),
                                ),
                                Container(
                                  width: 210,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.08),
                                        Colors.white.withOpacity(0.02),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: -rotation,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.navigation,
                                        size: 96,
                                        color: aligned
                                            ? AppColors.goldenHour
                                            : AppColors.textPrimary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        aligned ? 'Kıble Bulundu' : 'Kıble',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: aligned
                                          ? AppColors.goldenHour
                                          : AppColors.textTertiary,
                                      boxShadow: aligned
                                          ? [
                                              BoxShadow(
                                                color: AppColors.goldenHour
                                                    .withOpacity(0.4),
                                                blurRadius: 12,
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            _status,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            aligned
                                ? 'İşaret kıblede sabitlendi'
                                : 'Kıble ${bearing.toStringAsFixed(0)}° yönünde',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedOpacity(
                            opacity: aligned ? 1 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: AppColors.goldenHour),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kıble bulundu',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Telefonu düz tut ve oku kıbleye hizala',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: GlassCard(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    _loading ? 'Hazırlanıyor' : 'Canlı',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
