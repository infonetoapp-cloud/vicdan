import 'package:flutter/material.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/quran_local_datasource.dart';
import '../../data/repositories/quran_repository_impl.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../widgets/surah_card.dart';
import 'quran_radio_screen.dart';
import 'reading_screen.dart';

/// Main Quran screen displaying a list of all 114 surahs
///
/// Features:
/// - Scrollable list of surahs
/// - Search functionality (Turkish/Arabic names)
/// - Filter by revelation place (Makki/Madani)
/// - Glassmorphism design
/// - Navigation to reading screen
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  // Repository (TODO: Replace with dependency injection in Phase 2)
  late final QuranRepository _repository;

  // State
  List<Surah> _allSurahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Search
  final TextEditingController _searchController = TextEditingController();

  // Filter
  String? _selectedFilter; // null, 'makki', 'madani'

  @override
  void initState() {
    super.initState();
    _repository = QuranRepositoryImpl(QuranLocalDataSource());
    _loadSurahs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads all surahs from repository
  Future<void> _loadSurahs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final surahs = await _repository.getAllSurahs();
      setState(() {
        _allSurahs = surahs;
        _filteredSurahs = surahs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kur\'an verileri yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  /// Handles search query changes
  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = _applyFilter(_allSurahs);
      } else {
        final searchResults = _allSurahs.where((surah) {
          return surah.nameTurkish
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              surah.nameArabic.toLowerCase().contains(query.toLowerCase());
        }).toList();
        _filteredSurahs = _applyFilter(searchResults);
      }
    });
  }

  /// Applies revelation place filter
  List<Surah> _applyFilter(List<Surah> surahs) {
    if (_selectedFilter == null) return surahs;

    if (_selectedFilter == 'makki') {
      return surahs.where((s) => s.isMakki).toList();
    } else if (_selectedFilter == 'madani') {
      return surahs.where((s) => s.isMadani).toList();
    }

    return surahs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Search bar
              _buildSearchBar(),

              // Filter chips
              _buildFilterChips(),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          ),

          const SizedBox(width: 8),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kur\'an-ı Kerim',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                ),
                Text(
                  '${_filteredSurahs.length} Sure',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
              ],
            ),
          ),

          // Radio Button
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const QuranRadioScreen()));
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.radio,
                      color: AppColors.accentGold, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '7/24 Radyo',
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Sure ara (Fatiha, Bakara...)',
            hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.5)),
            prefixIcon:
                Icon(Icons.search, color: AppColors.textLight.withOpacity(0.7)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear,
                        color: AppColors.textLight.withOpacity(0.7)),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  /// Builds filter chips
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Mekki',
            icon: Icons.brightness_5,
            isSelected: _selectedFilter == 'makki',
            onTap: () {
              setState(() {
                _selectedFilter = _selectedFilter == 'makki' ? null : 'makki';
                _onSearchChanged();
              });
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Medeni',
            icon: Icons.nightlight_round,
            isSelected: _selectedFilter == 'madani',
            onTap: () {
              setState(() {
                _selectedFilter = _selectedFilter == 'madani' ? null : 'madani';
                _onSearchChanged();
              });
            },
          ),
        ],
      ),
    );
  }

  /// Builds a single filter chip
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.glassBorder,
            width: 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main content
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSurahs,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredSurahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                color: Colors.white.withOpacity(0.5), size: 48),
            const SizedBox(height: 16),
            Text(
              'Sonuç bulunamadı',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];
        return SurahCard(
          surah: surah,
          onTap: () => _navigateToReading(surah),
        );
      },
    );
  }

  /// Navigates to reading screen
  void _navigateToReading(Surah surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingScreen(surah: surah),
      ),
    );
  }
}
