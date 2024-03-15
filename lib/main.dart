import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'landing_page.dart';
import 'home_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensuring plugin services are initialized
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
      // Instead of directly setting the home property, using a builder to decide
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
        // other routes as needed
      },
    );
  }
}
