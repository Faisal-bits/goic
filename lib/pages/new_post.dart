import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logging/logging.dart';

final Logger logger = Logger('NewPost');

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitPost() async {
    if (!_isSubmitting) {
      setState(() => _isSubmitting = true);
      final postContent = _controller.text.trim();
      Position? position;
      String? userId = await _fetchUserId();

      try {
        position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .timeout(const Duration(seconds: 5),
                onTimeout: () =>
                    throw TimeoutException('Location request timed out'));
      } catch (e) {
        logger.warning(
            e); // Handle the timeout exception or any other exceptions accordingly
      }

      String? countryName;
      if (position != null) {
        countryName = await _getCountryNameFromPosition(position);
      } else {
        countryName = "Unknown"; // Fallback value if location is not available
      }

      if (userId != null) {
        // Create post object
        final post = {
          'userId': userId, // Use the fetched user ID
          'content': postContent,
          'location': position != null
              ? {
                  'lat': position.latitude,
                  'lng': position.longitude,
                  'country': countryName
                }
              : 'Unknown',
          'timestamp': FieldValue.serverTimestamp(),
          'likesCount': 0,
          'repliesCount': 0,
        };

        // Save to Firestore
        try {
          await FirebaseFirestore.instance.collection('posts').add(post);
          Navigator.of(context).pop(); // Navigate back after submitting
        } catch (e) {
          logger.warning("Failed to add post: $e");
        }
      } else {
        logger.warning("User ID not found, cannot submit post.");
      }

      setState(() => _isSubmitting = false);
    }
  }

  Future<String?> _fetchUserId() async {
    final userService = UserService();
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      return await userService.getUserIdByEmail(userEmail);
    }
    return null;
  }

  Future<String?> _getCountryNameFromPosition(Position position) async {
    try {
      // Use the geocoding package to perform reverse geocoding.
      // This call is wrapped in a Future that will timeout after 5 seconds.
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude)
              .timeout(const Duration(seconds: 5));
      Placemark place = placemarks[0];
      return place.country; // Return the country name
    } on TimeoutException catch (_) {
      logger.warning("Reverse geocoding request timed out.");
      return "Unknown"; // Return a fallback value if there is a timeout
    } catch (e) {
      logger.warning("Failed to get country name: $e");
      return "Unknown"; // Return a fallback value if any error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(labelText: "What's on your mind?"),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () async => await _submitPost(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                backgroundColor: Colors.blue, // Button background color
              ),
              child: const Text('Submit Post'),
            ),
          ],
        ),
      ),
    );
  }
}
