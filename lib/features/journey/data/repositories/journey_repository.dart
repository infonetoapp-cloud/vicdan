import 'package:shared_preferences/shared_preferences.dart';

class JourneyRepository {
  static const String _completedDaysKey = 'journey_completed_days';

  // RAMADAN 2026 START DATE (Estimated)
  // Adjust this as needed. For now using Feb 17, 2026.
  static final DateTime _ramadanStart = DateTime(2026, 2, 17);

  static const String _teravihKey = 'journey_teravih_days';
  static const String _hatimKey = 'journey_hatim_days';

  Future<Set<int>> getCompletedDays() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> completed = prefs.getStringList(_completedDaysKey) ?? [];
    return completed.map((e) => int.parse(e)).toSet();
  }

  Future<void> markDayCompleted(int day) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedDays();
    completed.add(day);
    await prefs.setStringList(
        _completedDaysKey, completed.map((e) => e.toString()).toList());
  }

  // --- TERAVIH TRACKER ---
  Future<Set<int>> getTeravihDays() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_teravihKey) ?? [];
    return list.map((e) => int.parse(e)).toSet();
  }

  Future<void> toggleTeravih(int day, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    final days = await getTeravihDays();
    if (completed) {
      days.add(day);
    } else {
      days.remove(day);
    }
    await prefs.setStringList(
        _teravihKey, days.map((e) => e.toString()).toList());
  }

  // --- HATIM/CÜZ TRACKER ---
  Future<Set<int>> getHatimDays() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_hatimKey) ?? [];
    return list.map((e) => int.parse(e)).toSet();
  }

  Future<void> toggleHatim(int day, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    final days = await getHatimDays();
    if (completed) {
      days.add(day);
    } else {
      days.remove(day);
    }
    await prefs.setStringList(
        _hatimKey, days.map((e) => e.toString()).toList());
  }

  // Returns the set of days that should be unlocked based on Current Date vs Ramadan Start
  Set<int> getUnlockedDays() {
    final now = DateTime.now();

    // If before Ramadan, only Day 1 is optionally visible/locked or just show countdown?
    // User requested: "Ramazan ne zaman başlıyorsa o gün ilk kilit açılsın"
    // This implies Day 1 unlocks on Feb 17.

    // Logic:
    // If now < RamadanStart, Day 0 is active (none unlocked? or just show countdown)
    // If now >= RamadanStart, Days = (Difference in Days) + 1

    final difference = now.difference(_ramadanStart).inDays;

    if (now.isBefore(_ramadanStart)) {
      // DEBUG: Unlock Day 1 so the user can see the features (Trackers, Detail Modal).
      return {1};
    }

    // Example: Feb 17 (Day 0 diff) -> Day 1 unlocked
    // Feb 18 (Day 1 diff) -> Day 1, 2 unlocked
    int daysUnlocked = difference + 1;

    // Cap at 30
    if (daysUnlocked > 30) daysUnlocked = 30;

    return List.generate(daysUnlocked, (index) => index + 1).toSet();
  }

  // For UI Countdown
  DateTime get ramadanStart => _ramadanStart;
}
