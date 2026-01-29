import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/datasources/prayer_checkin_store.dart';
import '../../data/repositories/prayer_times_repository.dart';
import 'qibla_screen.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final _locationService = LocationService();
  final _prayerRepo = PrayerTimesRepository();
  final _checkinStore = PrayerCheckinStore();
  Timer? _timer;

  bool _loading = true;
  bool _isCheckingIn = false;
  String _locationName = 'Konum alınıyor';
  String _nextPrayerName = '';
  String _nextPrayerTime = '-';
  DateTime? _nextPrayerDateTime;
  Map<String, String> _times = {};
  String _countdown = '-';
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadCachedLocation();
    _loadCompleted();
    _loadPrayerTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateCountdown();
    });
    _updateCountdown();
  }

  void _updateCountdown() {
    if (_nextPrayerDateTime == null) return;
    final diff = _nextPrayerDateTime!.difference(DateTime.now());
    if (diff.isNegative) return;
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final value = hours > 0 ? '$hours sa $minutes dk' : '$minutes dk';
    if (mounted) {
      setState(() {
        _countdown = value;
      });
    }
  }

  Future<void> _loadCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('location_name');
    if (cached != null && mounted) {
      setState(() {
        _locationName = cached;
      });
    }
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final position = await _locationService.determinePosition();
      final address =
          await _locationService.getAddressFromCoordinates(position);
      final data =
          _prayerRepo.getPrayerTimes(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _locationName = address;
          _nextPrayerName = data['next_prayer_name'] as String;
          _nextPrayerTime = data['next_prayer_time'] as String;
          _nextPrayerDateTime = data['next_prayer_datetime'] as DateTime?;
          _times = {
            'İmsak': data['fajr'] as String,
            'Güneş': data['sunrise'] as String,
            'Öğle': data['dhuhr'] as String,
            'İkindi': data['asr'] as String,
            'Akşam': data['maghrib'] as String,
            'Yatsı': data['isha'] as String,
          };
          _loading = false;
        });
      }
      _updateCountdown();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadCompleted() async {
    final completed = await _checkinStore.getCompleted(DateTime.now());
    if (mounted) {
      setState(() {
        _completed = completed;
      });
    }
  }

  bool _isCheckinAllowed(String prayerName) {
    return prayerName.isNotEmpty && prayerName != 'Güneş';
  }

  Future<void> _onCheckin() async {
    if (_isCheckingIn) return;
    if (!_isCheckinAllowed(_nextPrayerName)) return;
    setState(() {
      _isCheckingIn = true;
    });
    final completed =
        await _checkinStore.markCompleted(DateTime.now(), _nextPrayerName);
    if (mounted) {
      setState(() {
        _completed = completed;
        _isCheckingIn = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_nextPrayerName tamamlandı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          if (_loading)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Skeleton Header Card
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Skeleton List
                    ...List.generate(
                      6,
                      (index) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  _buildNextPrayerCard(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildPrayerList()),
                  const SizedBox(height: 12),
                  _buildFooterActions(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dateText = DateFormat('d MMMM EEEE', 'tr_TR').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _locationName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          dateText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard() {
    final isAllowed = _isCheckinAllowed(_nextPrayerName);
    final isCompleted = _completed.contains(_nextPrayerName);
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sıradaki',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                _nextPrayerName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                _countdown == '-' ? _nextPrayerTime : _countdown,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: isAllowed && !isCompleted ? _onCheckin : null,
            child: Text(
              isCompleted ? 'Kılındı' : 'Namazı Kıldım',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList() {
    final items = _times.entries.toList();
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = items[index];
        final isActive = entry.key == _nextPrayerName;
        final isCompleted = _completed.contains(entry.key);
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          opacity: isActive ? 0.2 : 0.12,
          borderOpacity: isActive ? 0.3 : 0.18,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isCompleted) ...[
                    const Icon(Icons.check_circle,
                        color: AppColors.goldenHour, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isCompleted
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
              Text(
                entry.value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isActive
                          ? AppColors.goldenHour
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooterActions() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.explore, color: AppColors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kıbleyi bul',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QiblaScreen()),
              );
            },
            child: const Text('Aç'),
          ),
        ],
      ),
    );
  }
}
