import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:adhan/adhan.dart';

/// Adhan sound options with local asset paths.
class AdhanSound {
  final String id;
  final String name;
  final String assetPath;
  final String? description;

  const AdhanSound({
    required this.id,
    required this.name,
    required this.assetPath,
    this.description,
  });
}

/// Available adhan sounds - using local assets.
class AdhanSounds {
  static const List<AdhanSound> all = [
    AdhanSound(
      id: 'mecca',
      name: 'Mekke Ezanı',
      assetPath: 'assets/audio/adhan_mecca.mp3',
      description: 'Mescid-i Haram',
    ),
    AdhanSound(
      id: 'medina',
      name: 'Medine Ezanı',
      assetPath: 'assets/audio/adhan_medina.mp3',
      description: 'Mescid-i Nebevi',
    ),
    AdhanSound(
      id: 'istanbul',
      name: 'İstanbul Ezanı',
      assetPath: 'assets/audio/adhan_istanbul.mp3',
      description: 'Klasik Türk Makamı',
    ),
    AdhanSound(
      id: 'mishary',
      name: 'Mişari Raşid',
      assetPath: 'assets/audio/adhan_mishary.mp3',
      description: 'Kuveyt',
    ),
  ];

  static AdhanSound getById(String id) {
    return all.firstWhere(
      (s) => s.id == id,
      orElse: () => all.first,
    );
  }
}

/// Service to manage Adhan notifications.
class AdhanNotificationService {
  static final AdhanNotificationService _instance =
      AdhanNotificationService._internal();
  factory AdhanNotificationService() => _instance;
  AdhanNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  AudioPlayer? _audioPlayer;
  bool _initialized = false;

  static const List<String> prayerKeys = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  static const Map<String, String> prayerNames = {
    'fajr': 'Sabah',
    'dhuhr': 'Öğle',
    'asr': 'İkindi',
    'maghrib': 'Akşam',
    'isha': 'Yatsı',
  };

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint("Notification tapped: ${response.payload}");
  }

  // ========== Global Toggle ==========
  Future<bool> isAdhanEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('adhan_enabled') ?? false;
  }

  Future<void> setAdhanEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_enabled', enabled);

    if (enabled) {
      await scheduleAllAdhanNotifications();
    } else {
      await cancelAllAdhanNotifications();
    }
  }

  // ========== Selected Adhan Sound ==========
  Future<String> getSelectedAdhanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_adhan_id') ?? 'mecca';
  }

  Future<void> setSelectedAdhanId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_adhan_id', id);
  }

  Future<AdhanSound> getSelectedAdhan() async {
    final id = await getSelectedAdhanId();
    return AdhanSounds.getById(id);
  }

  // ========== Per-Prayer Toggles ==========
  Future<bool> isPrayerAdhanEnabled(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('adhan_$prayerKey') ?? true;
  }

  Future<void> setPrayerAdhanEnabled(String prayerKey, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_$prayerKey', enabled);
    await scheduleAllAdhanNotifications();
  }

  Future<Map<String, bool>> getAllPrayerSettings() async {
    final Map<String, bool> settings = {};
    for (final key in prayerKeys) {
      settings[key] = await isPrayerAdhanEnabled(key);
    }
    return settings;
  }

  // ========== Prayer Time Calculation ==========
  Map<String, DateTime> _calculatePrayerTimes(double lat, double lng) {
    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethod.turkey.getParameters();
    params.madhab = Madhab.hanafi;

    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, params);

    return {
      'fajr': prayerTimes.fajr,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
    };
  }

  // ========== Scheduling ==========
  Future<void> scheduleAllAdhanNotifications() async {
    final isEnabled = await isAdhanEnabled();
    if (!isEnabled) return;

    await cancelAllAdhanNotifications();

    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('latitude') ?? 41.0082;
    final lng = prefs.getDouble('longitude') ?? 28.9784;

    final prayerTimes = _calculatePrayerTimes(lat, lng);
    final now = DateTime.now();

    for (int i = 0; i < prayerKeys.length; i++) {
      final key = prayerKeys[i];
      final isThisPrayerEnabled = await isPrayerAdhanEnabled(key);

      if (!isThisPrayerEnabled) continue;

      final prayerTime = prayerTimes[key];
      if (prayerTime == null) continue;

      if (prayerTime.isAfter(now)) {
        await _scheduleAdhanNotification(
          id: i,
          prayerName: prayerNames[key]!,
          scheduledTime: prayerTime,
        );
      }
    }
  }

  // ========== EQ Notification Messages (Soulful) ==========
  static const Map<String, List<String>> _soulfulMessages = {
    'fajr': [
      "Güneş doğmadan ruhunu aydınlat. 🌅",
      "Seher vakti, kalbinin en duyarlı anı.",
      "Yeni bir güne Bismillah de.",
      "Uykudan daha hayırlı bir çağrı var.",
    ],
    'dhuhr': [
      "Günün ortasında derin bir nefes al. ☀️",
      "Dünya işlerine kısa bir mola ver.",
      "Öğle sıcağında serin bir sığınak: Namaz.",
      "Ruhunun gıdasını ihmal etme.",
    ],
    'asr': [
      "Güneşin rengi değişiyor, asra yemin olsun. 🌇",
      "Zaman hızla akıyor, bir an dur ve hatırla.",
      "İkindi vakti, günün hesaplaşma provasıdır.",
      "Hüzün çökmeden kalbini ferahlat.",
    ],
    'maghrib': [
      "Akşamın hüznü çökerken, Rabbine sığın. 🌙",
      "Günün hesabını verme vakti.",
      "İftar sevinci gibi bir huzur seni bekliyor.",
      "Güneş battı ama umut bâki.",
    ],
    'isha': [
      "Gece sükuneti, ruhun dinlenme vakti. 🌌",
      "Günü huzurla kapat, yarına umutla uyan.",
      "Karanlıkta parlayan bir nur ol.",
      "En sevgiliyle buluşma anı.",
    ],
  };

  String _getRandomMessage(String prayerKey) {
    final messages = _soulfulMessages[prayerKey];
    if (messages == null || messages.isEmpty) {
      return "${prayerNames[prayerKey]} namazı vakti geldi";
    }
    return messages[
        DateTime.now().second % messages.length]; // Simple deterministic random
  }

  Future<void> _scheduleAdhanNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
  }) async {
    // Determine the key based on name (reverse lookup or pass key directly)
    // Since we only passed name, let's find the key.
    String key = prayerNames.entries
        .firstWhere((element) => element.value == prayerName,
            orElse: () => const MapEntry('fajr', 'Sabah'))
        .key;

    final soulfulMessage = _getRandomMessage(key);

    const androidDetails = AndroidNotificationDetails(
      'adhan_channel',
      'Ezan Bildirimleri',
      channelDescription: 'Namaz vakitlerinde ezan bildirimi',
      importance: Importance.high,
      priority: Priority.high,
      playSound:
          true, // Enable sound if needed, or handle custom sound via playsound:false logic
      sound: RawResourceAndroidNotificationSound(
          'adhan_mishary'), // Default gentle sound if available
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''), // Allow multiline text
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      sound: 'adhan_mishary.caf', // Ensure this file exists in iOS bundle
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      'Vakit Geldi 🕌', // Less mechanical title
      soulfulMessage, // POETIC MESSAGE HERE
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: prayerName,
    );

    debugPrint(
        "Scheduled EQ Adhan ($soulfulMessage) for $prayerName at $scheduledTime");
  }

  Future<void> cancelAllAdhanNotifications() async {
    for (int i = 0; i < prayerKeys.length; i++) {
      await _notifications.cancel(i);
    }
  }

  // ========== Audio Playback (Local Assets) ==========
  Future<void> playAdhan() async {
    try {
      final adhan = await getSelectedAdhan();
      _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setAsset(adhan.assetPath);
      await _audioPlayer!.play();
    } catch (e) {
      debugPrint("Error playing adhan: $e");
    }
  }

  Future<void> previewAdhan(String adhanId) async {
    try {
      final adhan = AdhanSounds.getById(adhanId);

      // Dispose and recreate player for each preview
      _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();

      debugPrint("Loading asset: ${adhan.assetPath}");
      await _audioPlayer!.setAsset(adhan.assetPath);
      debugPrint("Asset loaded, playing...");
      await _audioPlayer!.play();
      debugPrint("Playing adhan: ${adhan.name}");
    } catch (e) {
      debugPrint("Error previewing adhan: $e");
      rethrow;
    }
  }

  Future<void> stopAdhan() async {
    await _audioPlayer?.stop();
  }

  bool get isPlaying => _audioPlayer?.playing ?? false;

  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }
}
