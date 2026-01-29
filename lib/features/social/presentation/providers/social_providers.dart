import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../domain/repositories/social_repository.dart';
import '../../domain/entities/prayer_request.dart';

// Dependencies
// Dependencies
final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final sharedPrefsProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

// Repository Provider
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final prefs = ref.watch(sharedPrefsProvider);

  return SocialRepositoryImpl(firestore, prefs);
});

// Feed Stream Provider
final prayerFeedProvider = StreamProvider<List<PrayerRequest>>((ref) {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getPrayerFeed();
});

// My Requests Provider
final myRequestsProvider =
    FutureProvider.autoDispose<List<PrayerRequest>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getMyRequests();
});

// Amined IDs Provider (Local Cache)
final aminedPrayerIdsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getAminedPrayerIds();
});
