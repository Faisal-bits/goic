import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'package:goic/localization.dart';

final Logger logger = Logger('NewPost');

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({Key? key}) : super(key: key);

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitPost() async {
    if (_isSubmitting) return; // Prevent multiple submissions
    setState(() => _isSubmitting = true);

    final postContent = _controller.text.trim();
    if (postContent.isEmpty) {
      logger.warning("Post content cannot be empty.");
      setState(() => _isSubmitting = false);
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      logger.warning("User not logged in, cannot submit post.");
      setState(() => _isSubmitting = false);
      return;
    }

    // Optional: Fetch user location and country name
    String location = "Unknown"; // Default value if location isn't fetched

    // Post object
    final post = {
      'userId': userId,
      'content': postContent,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'repliesCount': 0,
    };

    // Attempt to save post to Firestore
    // In _submitPost method
    try {
      await FirebaseFirestore.instance.collection('posts').add(post);
      Navigator.pop(context, true); // Signal success
    } catch (e) {
      logger.warning("Failed to add post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add post. Please try again.')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.createPost ?? 'Create Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.whatsOnYourMind ??
                    "What's on your mind?",
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              child: Text(
                  AppLocalizations.of(context)?.submitPost ?? 'Submit Post'),
            ),
          ],
        ),
      ),
    );
  }
}
