import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../core/services/adhan_notification_service.dart';

/// Settings Screen with Adhan sound selection.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _prayerNotifications = true;
  bool _taskReminders = true;
  bool _adhanEnabled = false;
  String _selectedAdhanId = 'mecca';
  Map<String, bool> _prayerAdhanSettings = {};
  bool _isLoading = true;
  String? _previewingId;

  final AdhanNotificationService _adhanService = AdhanNotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _adhanService.initialize();

    final prefs = await SharedPreferences.getInstance();
    final adhanEnabled = await _adhanService.isAdhanEnabled();
    final selectedAdhanId = await _adhanService.getSelectedAdhanId();
    final prayerSettings = await _adhanService.getAllPrayerSettings();

    if (mounted) {
      setState(() {
        _prayerNotifications = prefs.getBool('prayer_notifications') ?? true;
        _taskReminders = prefs.getBool('task_reminders') ?? true;
        _adhanEnabled = adhanEnabled;
        _selectedAdhanId = selectedAdhanId;
        _prayerAdhanSettings = prayerSettings;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_notifications', _prayerNotifications);
    await prefs.setBool('task_reminders', _taskReminders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Ayarlar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            _adhanService.stopAdhan();
            Navigator.pop(context);
          },
        ),
      ),
      body: SkyGradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECTION: EZAN
          _buildSectionTitle("🕌 Ezan"),
          const SizedBox(height: 12),
          _buildAdhanSection(),

          const SizedBox(height: 32),

          // SECTION: Notifications
          _buildSectionTitle("Bildirimler"),
          const SizedBox(height: 12),
          _buildToggleTile(
            icon: Icons.mosque_rounded,
            title: "Namaz Vakti Bildirimleri",
            subtitle: "Ezan vaktinde hatırlatma al",
            value: _prayerNotifications,
            onChanged: (val) {
              setState(() => _prayerNotifications = val);
              _saveSettings();
            },
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            icon: Icons.task_alt_rounded,
            title: "Görev Hatırlatıcı",
            subtitle: "Günlük görev hatırlatması",
            value: _taskReminders,
            onChanged: (val) {
              setState(() => _taskReminders = val);
              _saveSettings();
            },
          ),

          const SizedBox(height: 32),

          // SECTION: Data
          _buildSectionTitle("Veri Yönetimi"),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.file_download_outlined,
            title: "Veriyi Dışa Aktar",
            subtitle: "Tüm verini JSON olarak indir",
            onTap: _exportData,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.delete_forever_rounded,
            title: "Tüm Verileri Sil",
            subtitle: "Dikkat: Bu işlem geri alınamaz",
            isDestructive: true,
            onTap: _confirmDeleteData,
          ),

          const SizedBox(height: 32),

          // SECTION: About
          _buildSectionTitle("Hakkında"),
          const SizedBox(height: 12),
          _buildInfoTile(
            icon: Icons.info_outline,
            title: "Versiyon",
            value: "1.0.0",
          ),
        ],
      ),
    );
  }

  /// Builds the Adhan section with master toggle, sound picker, and per-prayer toggles.
  Widget _buildAdhanSection() {
    return GlassCard(
      opacity: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Toggle
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.goldenHour.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.volume_up_rounded,
                      color: AppColors.goldenHour, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ezan Vakitlerinde Ezan Okusun",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Telefon sessizde ise çalmaz",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _adhanEnabled,
                  onChanged: (val) async {
                    setState(() => _adhanEnabled = val);
                    await _adhanService.setAdhanEnabled(val);
                  },
                  activeColor: AppColors.goldenHour,
                  activeTrackColor: AppColors.goldenHour.withOpacity(0.5),
                ),
              ],
            ),

            // Show options if enabled
            if (_adhanEnabled) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),

              // Sound Selection
              const Text(
                "Ezan Sesi Seçin",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...AdhanSounds.all.map((adhan) => _buildAdhanSoundTile(adhan)),

              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),

              // Per-Prayer Toggles
              const Text(
                "Hangi vakitlerde çalsın?",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildPrayerToggleRow('fajr', 'Sabah', '🌅'),
              _buildPrayerToggleRow('dhuhr', 'Öğle', '☀️'),
              _buildPrayerToggleRow('asr', 'İkindi', '🌤️'),
              _buildPrayerToggleRow('maghrib', 'Akşam', '🌆'),
              _buildPrayerToggleRow('isha', 'Yatsı', '🌙'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdhanSoundTile(AdhanSound adhan) {
    final isSelected = _selectedAdhanId == adhan.id;
    final isPreviewing = _previewingId == adhan.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () async {
          setState(() => _selectedAdhanId = adhan.id);
          await _adhanService.setSelectedAdhanId(adhan.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.goldenHour.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.goldenHour.withOpacity(0.5)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.goldenHour : Colors.white54,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.goldenHour,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Name & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adhan.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (adhan.description != null)
                      Text(
                        adhan.description!,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                  ],
                ),
              ),

              // Preview Button
              IconButton(
                icon: Icon(
                  isPreviewing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: isPreviewing ? AppColors.goldenHour : Colors.white54,
                ),
                onPressed: () async {
                  if (isPreviewing) {
                    await _adhanService.stopAdhan();
                    setState(() => _previewingId = null);
                  } else {
                    await _adhanService.stopAdhan();
                    setState(() => _previewingId = adhan.id);
                    try {
                      await _adhanService.previewAdhan(adhan.id);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Ses dosyası bulunamadı: ${adhan.name}"),
                            backgroundColor: Colors.orangeAccent,
                          ),
                        );
                        setState(() => _previewingId = null);
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerToggleRow(String key, String name, String emoji) {
    final isEnabled = _prayerAdhanSettings[key] ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          SizedBox(
            height: 32,
            child: Switch(
              value: isEnabled,
              onChanged: (val) async {
                setState(() => _prayerAdhanSettings[key] = val);
                await _adhanService.setPrayerAdhanEnabled(key, val);
              },
              activeColor: AppColors.sage,
              activeTrackColor: AppColors.sage.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.goldenHour,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GlassCard(
      opacity: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.sage,
              activeTrackColor: AppColors.sage.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GlassCard(
      opacity: 0.1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon,
                  color: isDestructive ? Colors.redAccent : Colors.white70,
                  size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDestructive ? Colors.redAccent : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDestructive
                            ? Colors.redAccent.withOpacity(0.7)
                            : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: isDestructive ? Colors.redAccent : Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return GlassCard(
      opacity: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Veri dışa aktarma özelliği yakında eklenecek..."),
        backgroundColor: AppColors.sage,
      ),
    );
  }

  void _confirmDeleteData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Tüm Verileri Sil?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Bu işlem geri alınamaz. Tüm görevler, ilerleme ve ayarlar silinecek.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Vazgeç", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllData();
            },
            child: const Text("Sil", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _adhanService.cancelAllAdhanNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tüm veriler silindi."),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context);
    }
  }
}
