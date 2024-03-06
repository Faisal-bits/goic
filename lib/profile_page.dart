import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'landing_page.dart';

class ProfilePage extends StatelessWidget {
  // Initialize GoogleSignIn
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    try {
      // Sign out from Google Sign-In
      await googleSignIn.signOut();
      // Then, sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();
      // After signing out, navigate to the LandingPage as the root page.
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () =>
                _signOut(context), // Call the updated sign-out function
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () =>
                  _signOut(context), // Call the updated sign-out function
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
