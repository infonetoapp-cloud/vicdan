import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class PrayerTimesRepository {
  /// Calculates prayer times for a given location and date
  /// Returns a Map with time strings (HH:mm) and the next prayer info
  Map<String, dynamic> getPrayerTimes(double latitude, double longitude) {
    final myCoordinates = Coordinates(latitude, longitude);

    // Turkey Standard: Diyanet calculation parameters
    final params = CalculationMethod.turkey.getParameters();
    params.madhab = Madhab.hanafi;

    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(myCoordinates, date, params);

    final nextPrayer = prayerTimes.nextPrayer();
    final nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);

    // Handle day rollover: if nextPrayer is none, set tomorrow's Fajr as next
    DateTime? effectiveNextTime = nextPrayerTime;
    String effectiveNextName = _getPrayerName(nextPrayer);
    if (nextPrayer == Prayer.none || nextPrayerTime == null) {
      final tomorrow = DateComponents.from(DateTime.now().add(const Duration(days: 1)));
      final tomorrowTimes = PrayerTimes(myCoordinates, tomorrow, params);
      effectiveNextTime = tomorrowTimes.fajr;
      effectiveNextName = _getPrayerName(Prayer.fajr);
    }

    return {
      'fajr': DateFormat.Hm().format(prayerTimes.fajr),
      'sunrise': DateFormat.Hm().format(prayerTimes.sunrise),
      'dhuhr': DateFormat.Hm().format(prayerTimes.dhuhr),
      'asr': DateFormat.Hm().format(prayerTimes.asr),
      'maghrib': DateFormat.Hm().format(prayerTimes.maghrib),
      'isha': DateFormat.Hm().format(prayerTimes.isha),
      'next_prayer_name': effectiveNextName,
      'next_prayer_time': effectiveNextTime != null ? DateFormat.Hm().format(effectiveNextTime) : '-',
      'next_prayer_datetime': effectiveNextTime,
    };
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'İmsak';
      case Prayer.sunrise:
        return 'Güneş';
      case Prayer.dhuhr:
        return 'Öğle';
      case Prayer.asr:
        return 'İkindi';
      case Prayer.maghrib:
        return 'Akşam';
      case Prayer.isha:
        return 'Yatsı';
      case Prayer.none:
        return 'Yatsı'; // Cycle completed
    }
  }
}
