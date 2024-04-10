import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/reply.dart';
import '../services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_post.dart';
import 'package:goic/localization.dart';
import 'package:logging/logging.dart';

final Logger logger = Logger('CommunityPage');

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final PostService _postService = PostService();

  Future<void> addTestPost() async {
    try {
      final postId = await FirebaseFirestore.instance.collection('posts').add({
        'userId': 'testUserId',
        'content': 'This is a test post',
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'likedByUsers': [],
      }).then((docRef) => docRef.id);

      logger.info("Test post added successfully with ID: $postId");
    } catch (e) {
      logger.warning(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.communities ?? 'Communities'),
      ),
      body: StreamBuilder<List<Post>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts found."));
          }
          final posts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              // refresh logic here
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  child: ListTile(
                    leading: post.profilePicUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(post.profilePicUrl!),
                            radius: 24,
                          )
                        : const CircleAvatar(
                            radius: 24, child: Icon(Icons.account_circle)),
                    title: Text(post.content),
                    subtitle: Text(
                        "${post.firstName ?? 'A user'}: ${post.likesCount} Likes, ${post.repliesCount} Replies"),
                    trailing: _buildTrailingIcons(post),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewPostScreen()));
          if (result == true) {
            setState(() {}); // refresh the list of posts
          }
        },
        tooltip: 'Create New Post',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTrailingIcons(Post post) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final isAdmin =
        FirebaseAuth.instance.currentUser?.email == 'admin@example.com';
    final isOwner = post.userId == userId;

    if (userId == null) {
      // Handle case when the user is not logged in
      return const SizedBox.shrink(); // Return an empty widget
    }

    bool alreadyLiked = post.likedByUsers.contains(userId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon:
              Icon(alreadyLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
          onPressed: () => _likePost(post.postId, alreadyLiked, userId),
        ),
        Text('${post.likesCount}'),
        IconButton(
          icon: const Icon(Icons.reply),
          onPressed: () => _showReplies(context, post),
        ),
        if (isAdmin || isOwner)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              try {
                await _postService.deletePost(post.postId);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post deleted successfully')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete post')),
                );
              }
            },
          ),
      ],
    );
  }

  void _likePost(String postId, bool alreadyLiked, String userId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      logger.info("User not logged in");
      return;
    }

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('posts').doc(postId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>? ?? {};

      int likesCount = postData['likesCount'] ?? 0;
      List likedByUsers = postData.containsKey('likedByUsers')
          ? List.from(postData['likedByUsers'])
          : [];

      if (alreadyLiked) {
        likesCount -= 1;
        likedByUsers.remove(userId);
      } else {
        likesCount += 1;
        if (!likedByUsers.contains(userId)) {
          likedByUsers.add(userId);
        }
      }

      transaction.update(
          postRef, {'likesCount': likesCount, 'likedByUsers': likedByUsers});
    }).then((result) {
      logger.info("Like updated successfully.");
      if (mounted) setState(() {}); // Refresh UI to reflect like change
    }).catchError((error) {
      logger.warning("Failed to update like: $error");
    });
  }

  void _showReplies(BuildContext context, Post post) {
    final TextEditingController replyController = TextEditingController();

    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Handle the case where the user is not logged in
      logger.info("User not logged in");
      // Optionally, show a message to the user or return to prevent opening the replies view
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // Adjust for keyboard
          child: FractionallySizedBox(
            heightFactor: 0.65,
            child: Column(
              children: <Widget>[
                AppBar(
                  title: const Text('Replies'),
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Use a StreamBuilder to listen for real-time updates to replies
                Expanded(
                  child: StreamBuilder<List<Reply>>(
                    stream: _postService.getRepliesForPost(post.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No replies yet.'));
                      }

                      var replies = snapshot.data!;
                      return ListView.builder(
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          var reply = replies[index];
                          return ListTile(
                            leading: reply.profilePicUrl != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(reply.profilePicUrl!))
                                : const CircleAvatar(
                                    child: Icon(Icons.account_circle)),
                            title: Text(reply.content),
                            subtitle: Text(
                                "${reply.firstName}: ${reply.likesCount} Likes"),
                            trailing: IconButton(
                              icon: Icon(
                                reply.likedByUsers.contains(userId)
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_alt_outlined,
                                color: reply.likedByUsers.contains(userId)
                                    ? Colors.blue
                                    : null,
                              ),
                              onPressed: () async {
                                // Determine the correct 'isLiked' state to pass
                                bool isLiked =
                                    !reply.likedByUsers.contains(userId);
                                await _postService.likeReply(
                                    post.postId, reply.replyId, isLiked);

                                // setState call might be needed if your UI does not automatically update
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          decoration: const InputDecoration(
                              hintText: "Write a reply..."),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          if (replyController.text.trim().isEmpty) {
                            logger.info("Reply field is empty");
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Reply cannot be empty")));
                            return;
                          }

                          logger.info(
                              "Submitting reply: ${replyController.text}");

                          try {
                            await _postService.addReplyToPost(
                                post.postId,
                                userId, // Use 'userId' here, ensuring it's defined and not null
                                replyController.text.trim());
                            logger.info("Reply submitted successfully");

                            replyController
                                .clear(); // Clear the text field after submitting
                            if (!mounted) return;
                            Navigator.pop(
                                context); // Optionally close the modal

                            // Trigger a state change to refresh the UI, like updating the reply count
                            setState(() {});
                          } catch (e) {
                            logger.warning("Failed to submit reply: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Failed to submit reply")));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) => replyController
        .clear()); // Ensure the controller is cleared when the sheet is dismissed
  }
}
