import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/social_repository.dart';
import '../../domain/entities/prayer_request.dart';
import '../models/prayer_request_model.dart';

class SocialRepositoryImpl implements SocialRepository {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs; // For getting local user ID if not auth'd

  SocialRepositoryImpl(this._firestore, this._prefs);

  String get _currentUserId => _prefs.getString('user_id') ?? 'unknown_user';
  String get _currentDisplayName => _prefs.getString('user_name') ?? 'Mümin';

  @override
  Stream<List<PrayerRequest>> getPrayerFeed() {
    return _firestore
        .collection('prayer_requests')
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrayerRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> createRequest(String content, bool isAnonymous) async {
    final model = PrayerRequestModel(
      id: '', // Firestore will generate
      userId: _currentUserId,
      userDisplayName: isAnonymous ? 'İsimsiz' : _currentDisplayName,
      content: content,
      aminCount: 0,
      createdAt: DateTime.now(),
      isAnonymous: isAnonymous,
      isApproved: false, // Pending moderation
    );

    await _firestore.collection('prayer_requests').add(model.toJson());
  }

  @override
  Future<bool> incrementAmin(String requestId) async {
    final docRef = _firestore.collection('prayer_requests').doc(requestId);
    final interactionRef =
        docRef.collection('interactions').doc(_currentUserId);

    // 1. Check local cache first to avoid unnecessary network calls
    final aminedList = await getAminedPrayerIds();
    if (aminedList.contains(requestId)) {
      return false; // Already amined locally
    }

    try {
      final success = await _firestore.runTransaction((transaction) async {
        // 2. Check if user already interacted in Firestore (Source of Truth)
        final interactionSnapshot = await transaction.get(interactionRef);
        if (interactionSnapshot.exists) {
          return false; // Already amined on server
        }

        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return false;

        // 3. Increment count and mark interaction
        final newCount = (snapshot.data()?['aminCount'] ?? 0) + 1;
        transaction.update(docRef, {'aminCount': newCount});
        transaction.set(interactionRef, {
          'timestamp': FieldValue.serverTimestamp(),
          'userId': _currentUserId,
        });

        return true;
      });

      if (success) {
        // 4. Update local cache
        await _addToAminedList(requestId);
      }

      return success;
    } catch (e) {
      // Handle potential race conditions or errors
      return false;
    }
  }

  @override
  Future<List<PrayerRequest>> getMyRequests() async {
    final snapshot = await _firestore
        .collection('prayer_requests')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PrayerRequestModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    await _firestore.collection('prayer_requests').doc(requestId).delete();
  }

  @override
  Future<List<String>> getAminedPrayerIds() async {
    return _prefs.getStringList('amined_prayers_$_currentUserId') ?? [];
  }

  Future<void> _addToAminedList(String requestId) async {
    final list = await getAminedPrayerIds();
    if (!list.contains(requestId)) {
      list.add(requestId);
      await _prefs.setStringList('amined_prayers_$_currentUserId', list);
    }
  }
}
