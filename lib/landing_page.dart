import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io'; // Import dart:io to use Platform.isIOS

import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'user_service.dart';

class LandingPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final authResult =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final User? user = authResult.user;

      if (user != null) {
        // Get the first name and last name from Apple credential
        String firstName = appleCredential.givenName ?? "";
        String lastName = appleCredential.familyName ?? "";

        // Fallback to split the display name if fullName not provided
        if (firstName.isEmpty && lastName.isEmpty) {
          List<String> names = user.displayName?.split(' ') ?? ["", ""];
          firstName = names.first;
          lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
        }

        String email = user.email ?? "";

        // Save user info to Firestore
        await UserService()
            .saveUserInfoToFirestore(user.uid, firstName, lastName, email);

        // Navigate to HomePage or handle the sign-in accordingly
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to sign in with Apple. Please try again.")),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          // Assuming displayName contains 'First Last'
          List<String> names = user.displayName?.split(' ') ?? ["", ""];
          String firstName = names.first;
          String lastName = names.length > 1
              ? names.sublist(1).join(' ')
              : ''; // Handles middle name too
          String email = user.email ?? "";

          // Save user info to Firestore
          await UserService()
              .saveUserInfoToFirestore(user.uid, firstName, lastName, email);

          // Navigate to the home page if the sign-in is successful
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (error) {
      print(error); // Handle the error appropriately in your app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to sign in with Google. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16), // Add some padding around the buttons
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00DAFC), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/goic.png', width: 200, height: 200),
            SizedBox(height: 50),
            // Google Sign-In Button
            ElevatedButton(
              onPressed: () => _signInWithGoogle(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .white, // Google's brand recommends a white background
                minimumSize: Size(
                    double.infinity, 50), // Full-width button with fixed height
                side: BorderSide(
                    color: Colors.grey.shade300), // Optional: border color
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/google.png', height: 24.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[
                            700], // Text color that contrasts with the button color
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Apple Sign-In Button - Conditionally rendered for iOS devices
            if (Platform.isIOS) // Check if the platform is iOS
              ElevatedButton.icon(
                icon: Icon(Icons.apple, color: Colors.white), // Apple logo
                label: Text('Continue with Apple ID',
                    style: TextStyle(color: Colors.white)),
                onPressed: () => _signInWithApple(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Apple's brand color
                  minimumSize: Size(double.infinity,
                      50), // Full-width button with fixed height
                ),
              ),
          ],
        ),
      ),
    );
  }
}
