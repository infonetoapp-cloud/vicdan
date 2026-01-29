import 'package:cloud_firestore/cloud_firestore.dart';

class SoulSignal {
  final String id;
  final DateTime timestamp;
  final String type; // 'daraldim', 'huzur', etc.
  final int prayerCount;
  final bool isActive;

  SoulSignal({
    required this.id,
    required this.timestamp,
    required this.type,
    this.prayerCount = 0,
    this.isActive = true,
  });

  factory SoulSignal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SoulSignal(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] ?? 'daraldim',
      prayerCount: data['prayerCount'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'prayerCount': prayerCount,
      'isActive': isActive,
    };
  }
}
