import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/landing_page.dart';
import 'navbar.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utility/maintain.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensuring plugin services are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  await correctLikesCountTypes();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color seedColor = Colors.blue;

    return MaterialApp(
      title: 'GOIC App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true, // Enable Material 3 features

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
              return const NavBar();
            }
            // User is not logged in
            return LandingPage();
          }
          // Waiting for authentication state to be available
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
      routes: {
        '/home': (context) => const NavBar(),
        // other routes ...
      },
    );
  }
}
