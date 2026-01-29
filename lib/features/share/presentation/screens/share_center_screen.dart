import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../data/special_days.dart';
import '../../utils/card_renderer.dart';
import '../widgets/tree_story_card.dart';
import '../widgets/cuma_card.dart';
import '../widgets/kandil_card.dart';
import '../widgets/bayram_card.dart';

/// Share Center Screen - Browse and share story cards
class ShareCenterScreen extends StatefulWidget {
  const ShareCenterScreen({super.key});

  @override
  State<ShareCenterScreen> createState() => _ShareCenterScreenState();
}

class _ShareCenterScreenState extends State<ShareCenterScreen> {
  final GlobalKey _cardKey = GlobalKey();
  int _selectedCardIndex = 0;
  bool _isSharing = false;

  // User stats
  int _streakDays = 0;
  double _healthScore = 50.0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _streakDays = prefs.getInt('current_streak') ?? 7;
      _healthScore = prefs.getDouble('health_score') ?? 50.0;
    });
  }

  List<ShareCardInfo> get _availableCards {
    final cards = <ShareCardInfo>[];

    // Always available: Tree Story Card
    cards.add(ShareCardInfo(
      title: 'Ağaç Hikayem',
      icon: '🌳',
      description: 'Yolculuğunu paylaş',
      builder: () => TreeStoryCard(
        streakDays: _streakDays,
        healthScore: _healthScore,
      ),
    ));

    // Check for special days
    final specialType = SpecialDays.getTodayType();

    if (specialType == SpecialDayType.bayram) {
      final bayram = SpecialDays.getTodayBayram()!;
      cards.insert(
          0,
          ShareCardInfo(
            title: bayram.name,
            icon: '🎉',
            description: 'Bayram tebriğini paylaş',
            builder: () => BayramCard(
              bayramName: bayram.name,
              message: bayram.message,
            ),
            isSpecial: true,
          ));
    } else if (specialType == SpecialDayType.kandil) {
      final kandil = SpecialDays.getTodayKandil()!;
      cards.insert(
          0,
          ShareCardInfo(
            title: kandil.name,
            icon: '🌙',
            description: 'Kandil mesajını paylaş',
            builder: () => KandilCard(
              kandilName: kandil.name,
              message: kandil.message,
            ),
            isSpecial: true,
          ));
    } else if (specialType == SpecialDayType.cuma) {
      cards.insert(
          0,
          ShareCardInfo(
            title: 'Cuma Mesajı',
            icon: '🕌',
            description: 'Hayırlı Cumalar',
            builder: () => const CumaCard(),
            isSpecial: true,
          ));
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final cards = _availableCards;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paylaşım Merkezi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SkyGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Card selector tabs
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final isSelected = index == _selectedCardIndex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCardIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (card.isSpecial
                                    ? AppColors.goldenHour
                                    : Colors.white)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: card.isSpecial && !isSelected
                                ? Border.all(
                                    color: AppColors.goldenHour, width: 2)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(card.icon,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                card.title,
                                style: TextStyle(
                                  color: isSelected
                                      ? (card.isSpecial
                                          ? Colors.white
                                          : Colors.black)
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (card.isSpecial) ...[
                                const SizedBox(width: 4),
                                const Text('✨', style: TextStyle(fontSize: 14)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Card preview
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: cards[_selectedCardIndex].builder(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Share buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _ShareButton(
                        icon: Icons.share_rounded,
                        label: 'Paylaş',
                        color: Colors.white,
                        isLoading: _isSharing,
                        onTap: _shareCard,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShareButton(
                        icon: Icons.save_alt_rounded,
                        label: 'Kaydet',
                        color: AppColors.goldenHour,
                        isLoading: false,
                        onTap: _saveCard,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareCard() async {
    setState(() => _isSharing = true);

    try {
      await CardRenderer.captureAndShare(
        _cardKey,
        text: 'VİCDAN uygulaması ile paylaştım 🌿',
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _saveCard() async {
    final path = await CardRenderer.saveToGallery(_cardKey);

    if (mounted && path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kart kaydedildi! 📸'),
          backgroundColor: AppColors.goldenHour,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

class ShareCardInfo {

  ShareCardInfo({
    required this.title,
    required this.icon,
    required this.description,
    required this.builder,
    this.isSpecial = false,
  });
  final String title;
  final String icon;
  final String description;
  final Widget Function() builder;
  final bool isSpecial;
}

class _ShareButton extends StatelessWidget {

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
