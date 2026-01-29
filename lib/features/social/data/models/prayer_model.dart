import 'package:cloud_firestore/cloud_firestore.dart';

class Prayer {
  final String id;
  final String content;
  final String categoryId; // 'sifa', 'sinav', 'rizik', 'sikinti', 'aile'
  final String authorId;
  final String nickname; // e.g. "İstanbul'dan Bir Kardeş" or "Gizli Ruh"
  final String status; // 'pending', 'approved', 'rejected'
  final int aminCount;
  final DateTime timestamp;
  final bool isAnonymous;

  Prayer({
    required this.id,
    required this.content,
    required this.categoryId,
    required this.authorId,
    required this.nickname,
    required this.status,
    required this.aminCount,
    required this.timestamp,
    required this.isAnonymous,
  });

  factory Prayer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Prayer(
      id: doc.id,
      content: data['content'] ?? '',
      categoryId: data['categoryId'] ?? 'sikinti',
      authorId: data['authorId'] ?? '',
      nickname: data['nickname'] ?? 'Gizli',
      status: data['status'] ?? 'pending',
      aminCount: data['aminCount'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnonymous: data['isAnonymous'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'categoryId': categoryId,
      'authorId': authorId,
      'nickname': nickname,
      'status': status,
      'aminCount': aminCount,
      'timestamp': FieldValue.serverTimestamp(),
      'isAnonymous': isAnonymous,
    };
  }
}
