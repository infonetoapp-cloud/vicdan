import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/social_providers.dart';

class CreatePrayerScreen extends ConsumerStatefulWidget {
  const CreatePrayerScreen({super.key});

  @override
  ConsumerState<CreatePrayerScreen> createState() => _CreatePrayerScreenState();
}

class _CreatePrayerScreenState extends ConsumerState<CreatePrayerScreen> {
  final _controller = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;

  void _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(socialRepositoryProvider)
          .createRequest(content, _isAnonymous)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dua İste'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                maxLength: 280,
                decoration: const InputDecoration(
                  hintText:
                      'Neye ihtiyacın var? (Örn: Sınavım için zihin açıklığı, hastalığım için şifa...)',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile.adaptive(
              value: _isAnonymous,
              onChanged: (val) => setState(() => _isAnonymous = val),
              title: const Text('İsimsiz Paylaş'),
              subtitle: const Text('Adın "İsimsiz" olarak görünecek.'),
              secondary: const Icon(LucideIcons.ghost),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    BorderSide(color: isDark ? Colors.white12 : Colors.black12),
              ),
              tileColor: theme.cardColor,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Duayı Gönder',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(LucideIcons.check, color: Color(0xFF10B981)),
            SizedBox(width: 12),
            Text('Dua Gönderildi'),
          ],
        ),
        content: const Text(
          'Duanız inceleme sonrası Amin Halkası\'nda yayınlanacaktır.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Tamam',
                style: TextStyle(
                    color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
