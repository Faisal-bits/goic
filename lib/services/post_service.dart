import '../models/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Post>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  Future<void> likePost(String postId) async {
    final userId =
        FirebaseAuth.instance.currentUser?.uid; // Get current user ID
    if (userId == null) return; // Ensure the user is logged in

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }
      final data = postSnapshot.data() as Map<String, dynamic>;
      final List<String> likedByUsers =
          List<String>.from(data['likedByUsers'] ?? []);
      final int currentLikes =
          data['likesCount'] ?? 0; // Ensure likesCount is treated as int

      if (likedByUsers.contains(userId)) {
        // User already liked the post, remove like
        likedByUsers.remove(userId);
        transaction.update(postRef, {
          'likedByUsers': likedByUsers,
          'likesCount': currentLikes - 1, // Decrement likesCount
        });
      } else {
        // User hasn't liked the post yet, add like
        likedByUsers.add(userId);
        transaction.update(postRef, {
          'likedByUsers': likedByUsers,
          'likesCount': currentLikes + 1, // Increment likesCount
        });
      }
    });
  }
}
