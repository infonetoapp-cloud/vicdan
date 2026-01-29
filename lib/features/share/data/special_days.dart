import 'package:hijri/hijri_calendar.dart';

/// Special Islamic days (Kandil, Bayram) detector.
class SpecialDays {
  /// Check if today is Friday (Cuma)
  static bool isFriday() {
    return DateTime.now().weekday == DateTime.friday;
  }

  /// Get current Hijri date
  static HijriCalendar getHijriDate() {
    return HijriCalendar.now();
  }

  /// Check if today is a Kandil night
  static KandilInfo? getTodayKandil() {
    final hijri = getHijriDate();

    for (final kandil in _kandiller) {
      if (hijri.hMonth == kandil['hijriMonth'] &&
          hijri.hDay == kandil['hijriDay']) {
        return KandilInfo(
          name: kandil['name'] as String,
          message: kandil['message'] as String,
        );
      }
    }

    // Special case for Regaib: First Friday of Recep
    if (hijri.hMonth == 7 && hijri.hDay <= 7 && isFriday()) {
      return KandilInfo(
        name: 'Regaib Kandili',
        message: 'Üç ayların başlangıcı, dualarınız kabul olsun',
      );
    }

    return null;
  }

  /// Check if today is Bayram
  static BayramInfo? getTodayBayram() {
    final hijri = getHijriDate();

    // Ramazan Bayramı: 1-3 Şevval (10. ay)
    if (hijri.hMonth == 10 && hijri.hDay >= 1 && hijri.hDay <= 3) {
      return BayramInfo(
        name: 'Ramazan Bayramı',
        day: hijri.hDay,
        message: 'Ramazan Bayramınız mübarek olsun!',
      );
    }

    // Kurban Bayramı: 10-13 Zilhicce (12. ay)
    if (hijri.hMonth == 12 && hijri.hDay >= 10 && hijri.hDay <= 13) {
      return BayramInfo(
        name: 'Kurban Bayramı',
        day: hijri.hDay - 9, // 1-4
        message: 'Kurban Bayramınız mübarek olsun!',
      );
    }

    return null;
  }

  /// Get today's special card type
  static SpecialDayType getTodayType() {
    if (getTodayBayram() != null) return SpecialDayType.bayram;
    if (getTodayKandil() != null) return SpecialDayType.kandil;
    if (isFriday()) return SpecialDayType.cuma;
    return SpecialDayType.normal;
  }

  static const List<Map<String, dynamic>> _kandiller = [
    {
      'name': 'Mevlid Kandili',
      'hijriMonth': 3, // Rebiülevvel
      'hijriDay': 12,
      'message': 'Peygamber Efendimizin doğum gecesi mübarek olsun',
    },
    {
      'name': 'Mirac Kandili',
      'hijriMonth': 7, // Recep
      'hijriDay': 27,
      'message': 'Miracın nurlu gecesi hayırlara vesile olsun',
    },
    {
      'name': 'Berat Kandili',
      'hijriMonth': 8, // Şaban
      'hijriDay': 15,
      'message': 'Affedilme ve beraat geceniz mübarek olsun',
    },
    {
      'name': 'Kadir Gecesi',
      'hijriMonth': 9, // Ramazan
      'hijriDay': 27,
      'message': 'Bin aydan hayırlı gece, dualarınız kabul olsun',
    },
  ];
}

enum SpecialDayType { normal, cuma, kandil, bayram }

class KandilInfo {

  KandilInfo({required this.name, required this.message});
  final String name;
  final String message;
}

class BayramInfo {

  BayramInfo({required this.name, required this.day, required this.message});
  final String name;
  final int day;
  final String message;
}
