import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vicdan_app/core/theme/app_colors.dart';
import 'package:vicdan_app/features/social/data/models/prayer_model.dart';
import 'package:vicdan_app/features/social/data/repositories/social_prayer_repository.dart';

class PrayerCard extends StatefulWidget {
  final Prayer prayer;

  const PrayerCard({super.key, required this.prayer});

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _aminController;
  late Animation<double> _scaleAnimation;
  bool _hasSaidAmin = false;
  int _localAminCount = 0;

  @override
  void initState() {
    super.initState();
    _localAminCount = widget.prayer.aminCount;
    _aminController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 2),
    ]).animate(
        CurvedAnimation(parent: _aminController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _aminController.dispose();
    super.dispose();
  }

  void _onAmin() async {
    if (_hasSaidAmin) return;

    setState(() {
      _hasSaidAmin = true;
      _localAminCount++;
    });

    _aminController.forward(from: 0);
    await SocialPrayerRepository().sayAmin(widget.prayer.id);
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'sifa':
        return AppColors.sage;
      case 'sinav':
        return Colors.blue.shade300;
      case 'rizik':
        return AppColors.accentGold;
      case 'sikinti':
        return Colors.purple.shade200;
      case 'aile':
        return AppColors.cherryBlossom;
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getCategoryLabel(String cat) {
    switch (cat) {
      case 'sifa':
        return 'Şifa';
      case 'sinav':
        return 'Sınav/Başarı';
      case 'rizik':
        return 'Rızık';
      case 'sikinti':
        return 'Huzur';
      case 'aile':
        return 'Aile';
      default:
        return 'Dua';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(widget.prayer.categoryId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCategoryLabel(widget.prayer.categoryId),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.prayer.isAnonymous
                    ? "Gizli Ruh"
                    : widget.prayer.nickname,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.prayer.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              fontFamily: 'CrimsonText',
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                DateFormat('dd MMM, HH:mm').format(widget.prayer.timestamp),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              const Spacer(),

              // Amin Button
              GestureDetector(
                onTap: _onAmin,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _hasSaidAmin
                        ? color.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                        color: _hasSaidAmin ? color : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          _hasSaidAmin ? Icons.spa : Icons.spa_outlined,
                          color: _hasSaidAmin ? color : Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasSaidAmin ? "Amin dendi" : "Amin de",
                        style: TextStyle(
                          color: _hasSaidAmin ? color : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$_localAminCount",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
