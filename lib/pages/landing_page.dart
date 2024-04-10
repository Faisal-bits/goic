import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io'; // importing dart:io to use Platform.isIOS
import 'package:logging/logging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../navbar.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Logger logger = Logger('LandingPage');

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Text editing controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus Nodes
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      logger.info("Apple Sign In Debug:");
      logger.info("Given Name: ${appleCredential.givenName}");
      logger.info("Family Name: ${appleCredential.familyName}");
      logger.info("Email: ${appleCredential.email}");

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final authResult = await _auth.signInWithCredential(oauthCredential);
      final User? user = authResult.user;

      if (user != null) {
        String firstName = appleCredential.givenName ?? "";
        String lastName = appleCredential.familyName ?? "";
        String email = appleCredential.email ?? "";

        if (email.isNotEmpty) {
          // Only save user info if email was provided
          await UserService()
              .saveUserInfoToFirestore(user.uid, firstName, lastName, email);
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const NavBar()));
      }
    } catch (error) {
      logger.warning(error);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to sign in with Apple. Please try again.")));
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
          // Check Firestore for existing user data
          final userData = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userData.exists) {
            List<String> names = user.displayName?.split(' ') ?? ["", ""];
            String firstName = names.first;
            String lastName =
                names.length > 1 ? names.sublist(1).join(' ') : '';
            String email = user.email ?? "";

            await UserService()
                .saveUserInfoToFirestore(user.uid, firstName, lastName, email);
          }
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const NavBar()));
        }
      }
    } catch (error) {
      logger.warning(error);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to sign in with Google. Please try again.")));
    }
  }

  Future<void> _createUserAccount(BuildContext context, String email,
      String password, String firstName, String lastName) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName("$firstName $lastName");

        // Using UserService to save user info to Firestore
        await _userService.saveUserInfoToFirestore(
            user.uid, firstName, lastName, email);

        // Navigate to the main screen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const NavBar()));
      }
    } on FirebaseAuthException catch (e) {
      logger.warning(e);
    }
  }

  void _showSignInOrRegisterSheet(BuildContext context,
      {bool isRegister = false}) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          final bottomInset = MediaQuery.of(bc).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRegister) ...[
                      TextField(
                        controller: firstNameController,
                        decoration:
                            const InputDecoration(labelText: 'First Name'),
                        textInputAction: TextInputAction.next,
                      ),
                      TextField(
                        controller: lastNameController,
                        decoration:
                            const InputDecoration(labelText: 'Last Name'),
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      textInputAction: isRegister
                          ? TextInputAction.done
                          : TextInputAction.next,
                      onSubmitted: (_) => isRegister
                          ? _createUserAccount(
                              context,
                              emailController.text,
                              passwordController.text,
                              firstNameController.text,
                              lastNameController.text)
                          : null,
                    ),
                    ElevatedButton(
                      onPressed: () => isRegister
                          ? _createUserAccount(
                              context,
                              emailController.text,
                              passwordController.text,
                              firstNameController.text,
                              lastNameController.text)
                          : _signInWithEmail(context, emailController.text,
                              passwordController.text),
                      child: Text(isRegister ? 'Register' : 'Sign In'),
                    ),
                    if (!isRegister) // Only show "Forgot Password?" if in sign-in mode
                      TextButton(
                        onPressed: () =>
                            _showForgotPasswordDialog(context, emailController),
                        child: const Text("Forgot Password?"),
                      ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the current sheet
                        _showSignInOrRegisterSheet(context,
                            isRegister: !isRegister);
                      },
                      child: Text(isRegister
                          ? "Already have an account? Sign In"
                          : "Don't have an account? Register"),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showForgotPasswordDialog(
      BuildContext context, TextEditingController emailController) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: "Enter your email address",
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _sendPasswordResetEmail(context, emailController.text);
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail(
      BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset link sent to $email")));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to send password reset email: ${e.message}")));
    }
  }

  Future<void> _signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NavBar()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Failed to sign in. Please check your email and password.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16), // some padding around the buttons
        decoration: const BoxDecoration(
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
            const SizedBox(height: 50),
            // Google Sign-In Button
            ElevatedButton(
              onPressed: () => _signInWithGoogle(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .white, // Google's brand recommends a white background
                minimumSize: const Size(
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
            const SizedBox(height: 20),
            // Apple Sign-In Button - Conditionally rendered for iOS devices
            if (Platform.isIOS) // Check if the platform is iOS
              ElevatedButton.icon(
                icon:
                    const Icon(Icons.apple, color: Colors.white), // Apple logo
                label: const Text('Continue with Apple ID',
                    style: TextStyle(color: Colors.white)),
                onPressed: () => _signInWithApple(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Apple's brand color
                  minimumSize: const Size(double.infinity,
                      50), // Full-width button with fixed height
                ),
              ),
            const Divider(),
            const Text('or'),
            ElevatedButton(
              onPressed: () => _showSignInOrRegisterSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Light grey color
                foregroundColor: Colors.black, // Text color
                minimumSize: const Size(double.infinity,
                    50), // Full-width button with fixed height // Optional: border color
              ),
              child: Text(
                'Continue with Email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800], // Darker text color for contrast
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
