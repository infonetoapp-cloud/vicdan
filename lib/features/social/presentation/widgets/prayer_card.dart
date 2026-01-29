import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/prayer_request.dart';
import '../providers/social_providers.dart';

class PrayerCard extends ConsumerWidget {
  final PrayerRequest request;

  const PrayerCard({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.user,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.userDisplayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM HH:mm').format(request.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _AminButton(request: request),
            ],
          ),
        ],
      ),
    );
  }
}

class _AminButton extends ConsumerStatefulWidget {
  final PrayerRequest request;

  const _AminButton({required this.request});

  @override
  ConsumerState<_AminButton> createState() => _AminButtonState();
}

class _AminButtonState extends ConsumerState<_AminButton> {
  bool _isOptimisticAmined = false;
  late int _localCount;

  @override
  void initState() {
    super.initState();
    _localCount = widget.request.aminCount;
  }

  Future<void> _handleTap() async {
    final aminedIds = ref.read(aminedPrayerIdsProvider).value ?? [];
    if (aminedIds.contains(widget.request.id) || _isOptimisticAmined) return;

    setState(() {
      _isOptimisticAmined = true;
      _localCount++;
    });

    final success = await ref
        .read(socialRepositoryProvider)
        .incrementAmin(widget.request.id);

    if (!success && mounted) {
      setState(() {
        _isOptimisticAmined = false;
        _localCount--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Zaten amin dediniz veya bir hata oluştu.')),
      );
    } else {
      // Refresh the amined IDs list to persist the state
      ref.invalidate(aminedPrayerIdsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aminedIdsAsync = ref.watch(aminedPrayerIdsProvider);
    final isAlreadyAmined = aminedIdsAsync.maybeWhen(
      data: (ids) => ids.contains(widget.request.id),
      orElse: () => false,
    );

    final isAmined = isAlreadyAmined || _isOptimisticAmined;

    return GestureDetector(
      onTap: isAmined ? null : _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isAmined
              ? const Color(0xFF10B981).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAmined
                ? const Color(0xFF10B981)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.heart_handshake,
              size: 18,
              color: isAmined ? const Color(0xFF10B981) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              'Amin ($_localCount)',
              style: TextStyle(
                color: isAmined ? const Color(0xFF10B981) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
