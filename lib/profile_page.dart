import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'landing_page.dart';

class ProfilePage extends StatelessWidget {
  // Initialize GoogleSignIn
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    try {
      // Check if the user signed in with Google and then sign out
      final GoogleSignInAccount? googleUser = await googleSignIn.currentUser;
      if (googleUser != null) {
        await googleSignIn.signOut();
      }

      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // After signing out, navigate to the LandingPage as the root page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingPage()),
      );
    } catch (error) {
      print("Error signing out: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Space out the main axis
        children: [
          Column(
            children: [
              SizedBox(height: 20), // Provide some spacing from the app bar
              CircleAvatar(
                radius: 60, // Size of the profile picture
                backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150'), // Example image
                backgroundColor: Colors.grey.shade200,
              ),
              SizedBox(height: 20), // Spacing after the profile picture
              ElevatedButton(
                onPressed: () {
                  // Placeholder for language switch functionality
                  print("Language switch button pressed");
                },
                child: Text('Switch Language'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue, // Button color
                  onPrimary: Colors.white, // Text color
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.all(16.0), // Padding around the logout button
            child: ElevatedButton(
              onPressed: () =>
                  _signOut(context), // Call the updated sign-out function
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Button color
                onPrimary: Colors.white, // Text color
                minimumSize: Size(double.infinity, 50), // Button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
