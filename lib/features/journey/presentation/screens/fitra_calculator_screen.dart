import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

class FitraCalculatorScreen extends StatefulWidget {
  const FitraCalculatorScreen({super.key});

  @override
  State<FitraCalculatorScreen> createState() => _FitraCalculatorScreenState();
}

class _FitraCalculatorScreenState extends State<FitraCalculatorScreen> {
  // Diyanet 2026 Fitre Miktarı
  double _fitraAmount = 240.0;
  int _personCount = 1;

  @override
  Widget build(BuildContext context) {
    final totalAmount = _fitraAmount * _personCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundTop, // High Contrast Theme
      appBar: AppBar(
        title: const Text(
          'Fitre Hesaplayıcı',
          style:
              TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          color: AppColors.textDark,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Fitre (Fıtır Sadakası), Ramazan ayında verilmesi vacip olan bir sadakadır. Miktar, bir kişinin bir günlük gıda ihtiyacıdır.",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Input Section
            GlassCard(
              opacity: 1.0, // Solid White
              borderOpacity: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kişi Başı Miktar (TL)',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: 'TL',
                      suffixStyle: const TextStyle(
                          color: AppColors.textLight, fontSize: 18),
                      helperText: 'Diyanet Tarafından Belirlenen',
                    ),
                    onChanged: (val) {
                      setState(() {
                        _fitraAmount = double.tryParse(val) ?? 0;
                      });
                    },
                    controller: TextEditingController(
                        text: _fitraAmount.toStringAsFixed(0))
                      ..selection = TextSelection.fromPosition(TextPosition(
                          offset: _fitraAmount.toStringAsFixed(0).length)),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Ailedeki Kişi Sayısı',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Person Counter
                  Row(
                    children: [
                      _buildCounterBtn(Icons.remove, () {
                        if (_personCount > 1) setState(() => _personCount--);
                      }),
                      Expanded(
                        child: Text(
                          '$_personCount Kişi',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      _buildCounterBtn(Icons.add, () {
                        setState(() => _personCount++);
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Result Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.softGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'TOPLAM FİTRE MİKTARI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${totalAmount.toStringAsFixed(0)} TL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Bu miktar asgaridir, gücünüze göre artırabilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: AppColors.textDark),
      ),
    );
  }
}
