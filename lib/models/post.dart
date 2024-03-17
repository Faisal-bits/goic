import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;
  final int likesCount;
  final int repliesCount;
  final List<String> likedByUsers;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.likesCount,
    required this.likedByUsers,
    required this.repliesCount,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Post(
      postId: doc.id,
      userId: data['userId'],
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likesCount: data['likesCount'],
      repliesCount: data['repliesCount'],
      likedByUsers: List<String>.from(data['likedByUsers'] ?? []),
    );
  }
}
