import 'package:equatable/equatable.dart';

class PrayerRequest extends Equatable {
  final String id;
  final String userId;
  final String userDisplayName;
  final String content;
  final int aminCount;
  final DateTime createdAt;
  final bool isAnonymous;
  final bool isApproved;

  const PrayerRequest({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.content,
    required this.aminCount,
    required this.createdAt,
    required this.isAnonymous,
    this.isApproved = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userDisplayName,
        content,
        aminCount,
        createdAt,
        isAnonymous,
        isApproved,
      ];
}
