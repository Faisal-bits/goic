import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../models/reply.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Post>> getPosts() {
    // Return a stream of list of posts
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // Use asyncMap to wait for all asynchronous operations within the stream
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
          print("Error fetching user data: $e");
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

      // Cast the data to Map<String, dynamic> to safely use the '[]' operator.
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
      print("Reply added and post's reply count updated successfully.");
    }).catchError((error) {
      print("Failed to add reply: $error");
    });
  }

  Stream<List<Reply>> getRepliesForPost(String postId) async* {
    // Listen to reply snapshots
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

        // Use the enriched data to create a Reply object
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
      print("User not logged in");
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
      print("Reply like updated successfully.");
    }).catchError((error) {
      print("Failed to update reply like: $error");
    });
  }
}
