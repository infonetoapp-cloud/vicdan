import '../entities/prayer_request.dart';

abstract class SocialRepository {
  Stream<List<PrayerRequest>> getPrayerFeed();
  Future<void> createRequest(String content, bool isAnonymous);
  Future<bool> incrementAmin(String requestId);
  Future<List<PrayerRequest>> getMyRequests();
  Future<void> deleteRequest(String requestId);
  Future<List<String>> getAminedPrayerIds();
}
