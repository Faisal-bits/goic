// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'landing_page.dart';
import 'package:logging/logging.dart';
import 'package:easy_localization/easy_localization.dart';

final Logger logger = Logger('ProfilePage');

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // Initialize GoogleSignIn
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    try {
      // Attempt to sign out from Google first
      await googleSignIn.signOut();
      logger.info('Google user signed out.');

      // Then, sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();
      logger.info('Firebase user signed out.');

      // After successfully signing out, navigate to the LandingPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingPage()),
      );
    } catch (error) {
      logger.warning("Error signing out: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile_page_title'.tr()),
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Space out the main axis
        children: [
          Column(
            children: [
              const SizedBox(
                  height: 20), // Provide some spacing from the app bar
              CircleAvatar(
                radius: 60, // Size of the profile picture
                backgroundImage: const NetworkImage(
                    'https://via.placeholder.com/150'), // Example image
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 20), // Spacing after the profile picture
              ElevatedButton(
                onPressed: () => context.locale = Locale('en'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Button color
                  foregroundColor: Colors.white, // Text color
                ),
                child: const Text('عربي'),
              ),
              const SizedBox(height: 10), // Provide spacing between buttons
              ElevatedButton(
                onPressed: () => context.locale = Locale('ar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Button color
                  foregroundColor: Colors.white, // Text color
                ),
                child: const Text('English'),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.all(16.0), // Padding around the logout button
            child: ElevatedButton(
              onPressed: () =>
                  _signOut(context), // Call the updated sign-out function

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Button color
                foregroundColor: Colors.white, // Text color
                minimumSize: const Size(double.infinity, 50), // Button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
              child: Text('logout_btn'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
