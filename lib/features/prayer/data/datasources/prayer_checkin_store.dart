import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerCheckinStore {
  Future<Set<String>> getCompleted(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date);
    final values = prefs.getStringList(key) ?? [];
    return values.toSet();
  }

  Future<Set<String>> markCompleted(DateTime date, String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date);
    final values = prefs.getStringList(key) ?? [];
    if (!values.contains(prayerName)) {
      values.add(prayerName);
      await prefs.setStringList(key, values);
    }
    return values.toSet();
  }

  String _keyForDate(DateTime date) {
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    return 'prayer_completed_$formatted';
  }
}
