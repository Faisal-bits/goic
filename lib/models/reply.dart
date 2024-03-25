import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String replyId;
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;
  String? firstName;
  int likesCount;
  List<String> likedByUsers;
  String? profilePicUrl;

  Reply({
    required this.replyId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.firstName,
    this.likesCount = 0,
    this.likedByUsers = const [],
    this.profilePicUrl,
  });

  factory Reply.fromDocumentSnapshot(DocumentSnapshot doc,
      {String? firstName, String? profilePicUrl}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return Reply(
      replyId: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: data['likesCount'] ?? 0,
      likedByUsers: List<String>.from(data['likedByUsers'] ?? []),
      profilePicUrl: profilePicUrl,
      firstName: firstName ?? 'User',
    );
  }
}
