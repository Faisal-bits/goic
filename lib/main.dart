import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Ensure you've imported firebase_core
import 'landing_page.dart';
import 'home_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import only the pages you're going to use immediately after sign-in

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure plugin services are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      // Instead of directly setting the home property, use a builder to decide
      // which initial route to use based on the authentication state.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // User is logged in
            if (snapshot.hasData) {
              return HomePage();
            }
            // User is not logged in
            return LandingPage();
          }
          // Waiting for authentication state to be available
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
      routes: {
        '/home': (context) => HomePage(),
        // Define other routes as needed
      },
    );
  }
}
