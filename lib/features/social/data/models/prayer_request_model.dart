import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/prayer_request.dart';

class PrayerRequestModel extends PrayerRequest {
  const PrayerRequestModel({
    required super.id,
    required super.userId,
    required super.userDisplayName,
    required super.content,
    required super.aminCount,
    required super.createdAt,
    required super.isAnonymous,
    super.isApproved,
  });

  factory PrayerRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrayerRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? 'İsimsiz',
      content: data['content'] ?? '',
      aminCount: data['aminCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAnonymous: data['isAnonymous'] ?? false,
      isApproved: data['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'content': content,
      'aminCount': aminCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAnonymous': isAnonymous,
      'isApproved': isApproved,
    };
  }

  PrayerRequestModel copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? content,
    int? aminCount,
    DateTime? createdAt,
    bool? isAnonymous,
    bool? isApproved,
  }) {
    return PrayerRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      content: content ?? this.content,
      aminCount: aminCount ?? this.aminCount,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
