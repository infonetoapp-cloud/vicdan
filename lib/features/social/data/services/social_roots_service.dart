import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/soul_signal.dart';

class SocialRootsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'soul_signals';

  // Singleton
  static final SocialRootsService _instance = SocialRootsService._internal();
  factory SocialRootsService() => _instance;
  SocialRootsService._internal();

  /// Emits a signal (e.g. "Daraldım") to the global root network.
  Future<String> emitSignal({String type = 'daraldim'}) async {
    try {
      final docRef = await _firestore.collection(collectionName).add({
        'timestamp': FieldValue.serverTimestamp(),
        'type': type,
        'prayerCount': 0,
        'isActive': true,
      });
      return docRef.id;
    } catch (e) {
      debugPrint("Error emitting soul signal: $e");
      return '';
    }
  }

  /// Sends a prayer/fatiha to a specific signal node.
  Future<void> sendPrayer(String signalId) async {
    try {
      await _firestore.collection(collectionName).doc(signalId).update({
        'prayerCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint("Error sending prayer: $e");
    }
  }

  /// Listens to active signals from the last 1 hour.
  Stream<List<SoulSignal>> listenToGlobalRoots() {
    // Current time minus 1 hour (approx, handled better by serverTimestamp usually but client side generic filter helps)
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

    return _firestore
        .collection(collectionName)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(oneHourAgo))
        .orderBy('timestamp', descending: true)
        .limit(20) // Don't overload the client
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SoulSignal.fromFirestore(doc)).toList());
  }
}
