import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JournalEntry {
  final String id;
  final String text;
  final DateTime date;
  final String type; // 'gratitude', 'feeling', etc.

  JournalEntry({
    required this.id,
    required this.text,
    required this.date,
    this.type = 'gratitude',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'date': date.toIso8601String(),
        'type': type,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'],
        text: json['text'],
        date: DateTime.parse(json['date']),
        type: json['type'] ?? 'gratitude',
      );
}

class JournalRepository {
  static const String _key = 'soul_journal_entries';

  Future<List<JournalEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => JournalEntry.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addEntry(String text, {String type = 'gratitude'}) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();

    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      date: DateTime.now(),
      type: type,
    );

    entries.add(newEntry);

    // Keep only last 365 entries for performance in this lite version
    if (entries.length > 365) {
      entries.removeAt(0);
    }

    await prefs.setString(
        _key, json.encode(entries.map((e) => e.toJson()).toList()));
  }
}
