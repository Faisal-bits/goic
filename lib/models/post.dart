import 'package:cloud_firestore/cloud_firestore.dart';
import 'reply.dart';

class Post {
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;
  int likesCount; // Mutable to allow updates in the UI
  int repliesCount;
  List<String> likedByUsers; // Mutable to allow updates in the UI
  String? firstName; // Optional user's first name
  String? profilePicUrl; // Optional URL to the user's profile picture

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.likesCount,
    required this.repliesCount,
    required this.likedByUsers,
    this.firstName,
    this.profilePicUrl,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Safe casting with fallbacks for null or missing values
    DateTime timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    int likesCount =
        data['likesCount'] != null ? (data['likesCount'] as num).toInt() : 0;
    int repliesCount = data['repliesCount'] != null
        ? (data['repliesCount'] as num).toInt()
        : 0;
    List<String> likedByUsers = data['likedByUsers'] != null
        ? List<String>.from(data['likedByUsers'])
        : [];

    return Post(
      postId: doc.id,
      userId: data['userId'],
      content: data['content'],
      timestamp: timestamp,
      likesCount: likesCount,
      repliesCount: repliesCount,
      likedByUsers: likedByUsers,
    );
  }

  Future<List<Reply>> getRepliesForPost(String postId) async {
    final replyDocs = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('replies')
        .orderBy('timestamp')
        .get();

    return replyDocs.docs
        .map((doc) => Reply.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> addReply(String postId, String userId, String content) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('replies')
        .add({
      'postId': postId,
      'userId': userId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void updateUserInfo({String? firstName, String? profilePicUrl}) {
    this.firstName = firstName;
    this.profilePicUrl = profilePicUrl;
  }
}
