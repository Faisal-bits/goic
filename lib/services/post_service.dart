import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../models/reply.dart';
import 'package:logging/logging.dart';

final Logger logger = Logger('PostPage');

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Post>> getPosts() {
    // Return a stream of list of posts
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Future<Post>> futures = snapshot.docs.map((doc) async {
        var postData = Post.fromFirestore(doc);
        try {
          var userData =
              await _db.collection('users').doc(postData.userId).get();
          postData.updateUserInfo(
            firstName: userData.data()?['firstName'] ?? '',
            profilePicUrl: userData.data()?['profilePicUrl'],
          );
        } catch (e) {
          logger.warning("Error fetching user data: $e");
        }
        return postData;
      }).toList();

      // Wait for all futures to complete
      return await Future.wait(futures);
    });
  }

  addReplyToPost(String postId, String userId, String content) async {
    var postRef = _db.collection('posts').doc(postId);
    var repliesCollectionRef = postRef.collection('replies');

    return _db.runTransaction((transaction) async {
      // Fetch the current post to ensure it exists and to get the current replies count.
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      var postData =
          postSnapshot.data() as Map<String, dynamic>?; // Safe cast to a map
      if (postData == null) {
        throw Exception("Post data is unexpectedly null");
      }
      int currentRepliesCount = postData['repliesCount'] ??
          0; // Now this line should work without error

      // Add the new reply
      DocumentReference newReplyRef = repliesCollectionRef
          .doc(); // Generates a new document with a unique ID
      transaction.set(newReplyRef, {
        'userId': userId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'likedByUsers': [],
      });

      // Increment the replies count in the original post
      transaction.update(postRef, {'repliesCount': currentRepliesCount + 1});
    }).then((result) {
      logger.info("Reply added and post's reply count updated successfully.");
    }).catchError((error) {
      logger.warning("Failed to add reply: $error");
    });
  }

  Stream<List<Reply>> getRepliesForPost(String postId) async* {
    yield* FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // For each reply, fetch additional user details
      var futures = snapshot.docs.map((doc) async {
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(doc['userId'])
            .get();

        return Reply.fromDocumentSnapshot(doc,
            firstName: userData.data()?['firstName'],
            profilePicUrl: userData.data()?['profilePicUrl']);
      });

      return await Future.wait(futures);
    });
  }

  Future<void> likeReply(String postId, String replyId, bool isLiked) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      logger.info("User not logged in");
      return;
    }

    DocumentReference replyRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('replies')
        .doc(replyId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot replySnapshot = await transaction.get(replyRef);
      if (!replySnapshot.exists) {
        throw Exception("Reply does not exist!");
      }

      int likesCount = replySnapshot['likesCount'] ?? 0;
      List likedByUsers = replySnapshot['likedByUsers'] != null
          ? List.from(replySnapshot['likedByUsers'])
          : [];

      if (isLiked && !likedByUsers.contains(userId)) {
        // Like the reply
        likesCount += 1;
        likedByUsers.add(userId);
      } else if (!isLiked && likedByUsers.contains(userId)) {
        // Unlike the reply
        likesCount -= 1;
        likedByUsers.remove(userId);
      } // If the conditions do not match, do nothing (user has already liked/unliked)

      transaction.update(replyRef, {
        'likesCount': likesCount,
        'likedByUsers': likedByUsers,
      });
    }).then((result) {
      logger.info("Reply like updated successfully.");
    }).catchError((error) {
      logger.warning("Failed to update reply like: $error");
    });
  }

  Stream<List<Post>> getPostsByMode(String mode) {
    return _db
        .collection('posts')
        .where('mode', isEqualTo: mode)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Future<Post>> futures = snapshot.docs.map((doc) async {
        var postData = Post.fromFirestore(doc);
        try {
          var userData =
              await _db.collection('users').doc(postData.userId).get();
          postData.updateUserInfo(
            firstName: userData.data()?['firstName'] ?? '',
            profilePicUrl: userData.data()?['profilePicUrl'],
          );
        } catch (e) {
          logger.warning("Error fetching user data: $e");
        }
        return postData;
      }).toList();

      // Wait for all futures to complete
      return await Future.wait(futures);
    });
  }

  Future<void> deletePost(String postId) async {
    try {
      // Delete the post document
      await _db.collection('posts').doc(postId).delete();

      // Delete all the replies associated with the post
      var repliesSnapshot =
          await _db.collection('posts').doc(postId).collection('replies').get();

      for (var replyDoc in repliesSnapshot.docs) {
        await replyDoc.reference.delete();
      }

      logger.info("Post and its replies deleted successfully.");
    } catch (error) {
      logger.warning("Failed to delete post: $error");
      throw error;
    }
  }

  Future<void> deleteReply(String postId, String replyId) async {
    var postRef = _db.collection('posts').doc(postId);
    var replyRef = postRef.collection('replies').doc(replyId);

    return _db.runTransaction((transaction) async {
      // Fetch the reply to ensure it exists
      DocumentSnapshot replySnapshot = await transaction.get(replyRef);
      if (!replySnapshot.exists) {
        throw Exception("Reply does not exist!");
      }

      // Fetch the post to update the replies count
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      var postData = postSnapshot.data() as Map<String, dynamic>?;
      if (postData == null) {
        throw Exception("Post data is unexpectedly null");
      }

      int currentRepliesCount = postData['repliesCount'] ?? 0;
      if (currentRepliesCount > 0) {
        // Decrement the replies count
        transaction.update(postRef, {'repliesCount': currentRepliesCount - 1});
      } else {
        logger.warning("Attempted to decrement replies count below zero.");
      }

      // Delete the reply document
      transaction.delete(replyRef);
    }).then((result) {
      logger.info(
          "Reply deleted and post's reply count decremented successfully.");
    }).catchError((error) {
      logger.warning("Failed to delete reply: $error");
      throw error;
    });
  }
}
