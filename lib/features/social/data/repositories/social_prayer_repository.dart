import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/prayer_model.dart';

class SocialPrayerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'prayers';
  final String interactionsCollection = 'prayer_interactions';

  // Singleton
  static final SocialPrayerRepository _instance =
      SocialPrayerRepository._internal();
  factory SocialPrayerRepository() => _instance;
  SocialPrayerRepository._internal();

  /// Submit a new prayer request
  Future<void> submitPrayer({
    required String content,
    required String categoryId,
    required bool isAnonymous,
    String? predefinedNickname, // e.g. "Istanbul'dan"
  }) async {
    try {
      // Create a temporary ID for the user if not auth'd (simple device fingerprinting approach could be used later)
      // For now using random UUID for authorId if anonymous
      final String authorId = const Uuid().v4();
      final String nickname =
          isAnonymous ? 'Gizli Ruh' : (predefinedNickname ?? 'Gönül Dostu');

      await _firestore.collection(collectionName).add({
        'content': content,
        'categoryId': categoryId,
        'authorId': authorId,
        'nickname': nickname,
        'status': 'pending', // Needs admin approval
        'aminCount': 0,
        'timestamp': FieldValue.serverTimestamp(),
        'isAnonymous': isAnonymous,
      });
    } catch (e) {
      debugPrint("Error submitting prayer: $e");
      rethrow;
    }
  }

  /// Stream approved prayers for the feed
  Stream<List<Prayer>> getApprovedPrayers() {
    return _firestore
        .collection(collectionName)
        .where('status', isEqualTo: 'approved')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Prayer.fromFirestore(doc)).toList());
  }

  /// Say "Amin" to a prayer
  Future<void> sayAmin(String prayerId) async {
    // Simple Increment for now.
    // In a full app, we would check sub-collection to prevent double-amin by same device.
    try {
      final docRef = _firestore.collection(collectionName).doc(prayerId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final newCount = (snapshot.data()?['aminCount'] ?? 0) + 1;
        transaction.update(docRef, {'aminCount': newCount});
      });
    } catch (e) {
      debugPrint("Error saying Amin: $e");
    }
  }
}
