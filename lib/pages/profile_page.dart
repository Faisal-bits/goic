import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'landing_page.dart';
import '../localization.dart';
import '../main.dart';

final Logger logger = Logger('ProfilePage');

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    try {
      await googleSignIn.signOut();
      logger.info('Google user signed out.');
      await FirebaseAuth.instance.signOut();
      logger.info('Firebase user signed out.');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LandingPage()));
    } catch (error) {
      logger.warning("Error signing out: $error");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error signing out: $error")));
    }
  }

  Future<void> _toggleLanguage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isArabic = prefs.getString('language_code') == 'ar';
    await prefs.setString('language_code', isArabic ? 'en' : 'ar');
    changeLocale(context, isArabic ? 'en' : 'ar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.profile ?? "Profile"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    const NetworkImage('https://via.placeholder.com/150'),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _toggleLanguage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)?.language ??
                    'Language / اللغة'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(AppLocalizations.of(context)?.logout ?? 'Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
