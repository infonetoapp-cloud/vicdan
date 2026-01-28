import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../home/presentation/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _locationService = LocationService();
  int _pageIndex = 0;
  double _socialHours = 2.5;
  String _locationName = '';
  String _district = '';
  bool _isLocationLoading = false;
  Position? _currentPosition;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setDouble('social_hours', _socialHours);
    if (_locationName.isNotEmpty) {
      await prefs.setString('location_name', _locationName);
    }

    // Save coordinates to prevent Home from re-fetching
    if (_currentPosition != null) {
      await prefs.setDouble('latitude', _currentPosition!.latitude);
      await prefs.setDouble('longitude', _currentPosition!.longitude);
    }

    if (!mounted) return;

    // Slow transition to home
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _nextPage() {
    // Name Validation
    if (_pageIndex == 1 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devam etmek için lütfen ismini yaz'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_pageIndex < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _pageIndex++);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: Stack(
        children: [
          // 1. Ferah Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
              ),
            ),
          ),

          // 2. Animated Flow
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWelcomeStep(),
                      _buildIdentityStep(),
                      _buildSocialMirrorStep(),
                      _buildLocationStep(),
                      _buildFinalStep(),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'VİCDAN',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppColors.primaryGreen,
            ),
          ).animate().fadeIn(duration: 600.ms),
          _buildDots(),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      children: List.generate(5, (index) {
        final isActive = _pageIndex == index;
        return AnimatedContainer(
          duration: 400.ms,
          width: isActive ? 20 : 6,
          height: 6,
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryGreen
                : AppColors.primaryGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeStep() {
    return _buildStepLayout(
      title: 'Vicdanına\nhoş geldin.',
      subtitle:
          'Seninle birlikte büyüyecek, ferah bir yaşam alanına ilk adımı atıyoruz.',
      child: Container(
        height: 200,
        alignment: Alignment.center,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primaryGreen.withOpacity(0.4),
                Colors.transparent
              ],
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 3.seconds,
                curve: Curves.easeInOut),
      ),
    );
  }

  Widget _buildIdentityStep() {
    return _buildStepLayout(
      title: 'Sana nasıl\nhitap edelim?',
      subtitle: 'Bu yolculukta sana özel bir remiz veya sadece ismin...',
      child: GlassCard(
        child: TextField(
          controller: _nameController,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: 'İsmin veya bir remiz...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMirrorStep() {
    final yearlyDays = (_socialHours * 365 / 24).round();
    final provocativeQuote = _socialHours > 4
        ? 'Hayatının $yearlyDays gününü ekranlara mı adıyorsun? Kendine dönme vakti gelmedi mi?'
        : 'Yılda tam $yearlyDays gününü başkalarını izleyerek geçiriyorsun. Kendi hikayeni ne zaman yazacaksın?';

    return _buildStepLayout(
      title: 'Zamanın\nVicdanı.',
      subtitle:
          'Günlük sosyal medya süren, aslında ömründen bir parça. Gel, beraber bakalım.',
      child: Column(
        children: [
          GlassCard(
            child: Column(
              children: [
                Text(
                  '${_socialHours.toStringAsFixed(1)} Saat / Gün',
                  style: AppTypography.scoreDisplay
                      .copyWith(color: AppColors.primaryGreen, fontSize: 32),
                ).animate(target: _socialHours).fadeIn(),
                Slider(
                  value: _socialHours,
                  min: 0,
                  max: 12,
                  divisions: 24,
                  activeColor: AppColors.primaryGreen,
                  inactiveColor: AppColors.primaryGreen.withOpacity(0.1),
                  onChanged: (v) => setState(() => _socialHours = v),
                ),
                Text(
                  'Yılda yaklaşık $yearlyDays GÜN',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.accentGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            provocativeQuote,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.primaryGreen,
                height: 1.5,
                fontSize: 16),
          )
              .animate(key: ValueKey(_socialHours))
              .fadeIn()
              .slideY(begin: 0.2, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildLocCard(String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              letterSpacing: 1,
              color: AppColors.textDark.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    final name = _nameController.text.trim();
    return _buildStepLayout(
      title: 'Hadi\nbaşlayalım, $name.',
      subtitle:
          'Vicdanın ferah, yolun aydınlık olsun. Yaşam alanına hoş geldin.',
      child: const Center(
        child:
            Icon(Icons.favorite_rounded, size: 80, color: AppColors.accentGold),
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(duration: 1.seconds, curve: Curves.elasticOut),
    );
  }

  Widget _buildStepLayout(
      {required String title,
      required String subtitle,
      required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 24, right: 24, top: 40), // Standard top padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                AppTypography.displayLarge.copyWith(height: 1.1, fontSize: 32),
          )
              .animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, curve: Curves.easeOutCubic),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textDark.withOpacity(0.6), height: 1.4),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 800.ms)
              .slideY(begin: 0.5, curve: Curves.easeOutCubic),
          const SizedBox(height: 48), // Separator
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: child
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      final position = await _locationService.determinePosition();
      // Store position for saving later
      _currentPosition = position;

      // Use new structured details for accurate City/District
      final details = await _locationService.getLocationDetails(position);
      final city = details['city'] ?? '';
      var district = details['district'] ?? '';

      // Default to "Merkez" ONLY if district is truly missing after all robust checks
      if (district.isEmpty || district == city) {
        district = "Merkez";
      }

      if (mounted) {
        setState(() {
          _locationName = city.isNotEmpty ? city : 'Bilinmiyor';
          _district = district;
          _isLocationLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationName = 'Konum Alınamadı';
          _district = '-';
          _isLocationLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Konum izni verilmezse namaz vakitlerini çekemeyeceğiz, bilginiz olsun.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Tamam',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Widget _buildLocationStep() {
    return _buildStepLayout(
      title: 'Huzuru nerede\narıyorsun?',
      subtitle:
          'Namaz vakitleri ve kıble için semtini bilmemiz gerekiyor. Merak etme; verilerin cihazından asla dışarı çıkmaz.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLocCard(
              'ŞEHİR', _locationName.isEmpty ? 'Bekleniyor...' : _locationName),
          const SizedBox(height: 12),
          _buildLocCard(
              'İLÇE', _district.isEmpty ? 'Bekleniyor...' : _district),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _isLocationLoading ? null : _requestLocation,
              icon: _isLocationLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.location_on_rounded),
              label: Text(_isLocationLoading
                  ? 'Konum Hesaplanıyor...'
                  : 'Konum İzni Ver'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                backgroundColor: AppColors.primaryGreen.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          if (_locationName == 'Konum Alınamadı')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'İzin verilmediği için varsayılan vakitler kullanılacak.',
                textAlign: TextAlign.center,
                style:
                    AppTypography.labelSmall.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isLast = _pageIndex == 4;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: Text(
            isLast ? 'Hadi Başlayalım' : 'Devam Et',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ).animate().fadeIn(delay: 1.seconds),
    );
  }
}
