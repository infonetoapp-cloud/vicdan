import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DigitalMahyaWidget extends StatelessWidget {

  const DigitalMahyaWidget({
    super.key,
    required this.message,
  });
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.goldenHour.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldenHour.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          // Minaret wires visualization (Optional/Stylized)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMinaretSymbol(),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white24,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              _buildMinaretSymbol(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.goldenHour,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontFamily: 'Inter', // Or a dot-matrix font if added later
              shadows: [
                Shadow(
                  color: AppColors.goldenHour,
                  blurRadius: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinaretSymbol() {
    return Container(
      width: 4,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
