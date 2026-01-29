import 'package:flutter/material.dart';
import 'package:vicdan_app/core/theme/app_colors.dart';
import 'package:vicdan_app/features/social/data/repositories/social_prayer_repository.dart';

class RequestPrayerTab extends StatefulWidget {
  const RequestPrayerTab({super.key});

  @override
  State<RequestPrayerTab> createState() => _RequestPrayerTabState();
}

class _RequestPrayerTabState extends State<RequestPrayerTab> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'sikinti';
  bool _isAnonymous = true;
  bool _isLoading = false;

  final Map<String, String> _categories = {
    'sifa': 'Şifa',
    'sinav': 'Sınav/Başarı',
    'rizik': 'Rızık',
    'sikinti': 'Huzur/Sıkıntı',
    'aile': 'Aile',
  };

  final Map<String, Color> _categoryColors = {
    'sifa': AppColors.sage,
    'sinav': Colors.blue.shade300,
    'rizik': AppColors.accentGold,
    'sikinti': Colors.purple.shade200,
    'aile': AppColors.cherryBlossom,
  };

  Future<void> _submitPrayer() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await SocialPrayerRepository().submitPrayer(
        content: _contentController.text.trim(),
        categoryId: _selectedCategory,
        isAnonymous: _isAnonymous,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Duanız halkaya bırakıldı. Onaylandıktan sonra yayınlanacak.")),
        );
        _contentController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata oluştu: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Kalbinden geçenleri dök...",
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'CrimsonText',
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Category Selector
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final key = _categories.keys.elementAt(index);
                final label = _categories[key]!;
                final isSelected = _selectedCategory == key;
                final color = _categoryColors[key]!;

                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = key);
                  },
                  selectedColor: color.withOpacity(0.2),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? color : AppColors.textLight,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? color : Colors.transparent,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 5,
              maxLength: 280,
              decoration: const InputDecoration(
                hintText: "Duanı buraya yaz...",
                border: InputBorder.none,
                counterText: "",
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Privacy Toggle
          Row(
            children: [
              Switch(
                value: _isAnonymous,
                onChanged: (val) => setState(() => _isAnonymous = val),
                activeColor: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                _isAnonymous
                    ? "İsimsiz Paylaş (Gizli Ruh)"
                    : "Şehrimi Göster (Örn: İstanbul)",
                style: const TextStyle(color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _isLoading ? null : _submitPrayer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text("Halkaya Bırak",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 30),
          const Text(
            "\"Müminin mümin kardeşine gıyabında yaptığı dua kabul olunur.\"\n(Hadis-i Şerif)",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
