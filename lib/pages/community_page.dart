import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'new_post.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Communities')),
      body: StreamBuilder<List<Post>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                child: ListTile(
                  title: Text(post.content),
                  subtitle: Text(
                      "${post.likesCount} Likes, ${post.repliesCount} Replies"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          post.likedByUsers.contains(
                                  FirebaseAuth.instance.currentUser?.uid)
                              ? Icons.thumb_up // User has liked this post
                              : Icons
                                  .thumb_up_alt_outlined, // User has not liked this post
                        ),
                        onPressed: () async {
                          await _postService.likePost(post.postId);
                          setState(() {
                            // This is a placeholder for any state updates you need to make.
                            // Simply calling setState here tells Flutter to re-run build,
                            // leading to the StreamBuilder being rebuilt with the updated stream.
                          });
                        },
                      ),
                      Text('${post.likesCount}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => NewPostScreen())),
        tooltip: 'Create Post',
        child: Icon(Icons.add),
      ),
    );
  }
}
