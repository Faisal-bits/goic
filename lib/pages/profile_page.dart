import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'landing_page.dart';
import '../localization.dart';
import '../main.dart';
import 'package:permission_handler/permission_handler.dart';

final Logger logger = Logger('ProfilePage');

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  User? user;
  String? _profilePicUrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      var userData = await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        _firstNameController.text = userData.data()?['firstName'] ?? '';
        _lastNameController.text = userData.data()?['lastName'] ?? '';
        _profilePicUrl = userData.data()?['profilePicUrl'];
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    // Request permissions if they're not already granted.
    await _requestPermissions();

    // Continue with the image picking and uploading process.
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final file = await image.readAsBytes();
        final snapshot = await _storage
            .ref('profilePictures/${user!.uid}.png')
            .putData(file);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await _firestore
            .collection('users')
            .doc(user!.uid)
            .update({'profilePicUrl': downloadUrl});
        setState(() => _profilePicUrl = downloadUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    // Request storage permission.
    var storageStatus = await Permission.storage.request();

    // Optionally, request camera permission if need to take photos.
    // var cameraStatus = await Permission.camera.request();

    // Check the status of the permissions.
    if (!storageStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Storage permission is required to pick images.')),
      );
    }

    // Uncomment if camera permission is needed.
    // if (!cameraStatus.isGranted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Camera permission is required to take photos.')),
    //   );
    // }
  }

  void _saveChanges() async {
    await _firestore.collection('users').doc(user!.uid).update({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
    });
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              AppLocalizations.of(context)?.saveChanges ?? 'Changes saved!')),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await googleSignIn.signOut();
      await _auth.signOut();
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
    MyApp.of(context)?.setLocale(Locale(isArabic ? 'en' : 'ar'));
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.profile ?? "Profile"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildProfilePicture(),
              const SizedBox(height: 20),
              if (!_isEditing) ...[
                Directionality(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    _firstNameController.text,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                Directionality(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    _lastNameController.text,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)?.edit ?? 'Edit',
                    style:
                        const TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
              if (_isEditing) ...[
                _buildEditableTextField(
                  controller: _firstNameController,
                  label:
                      AppLocalizations.of(context)?.firstName ?? 'First Name',
                  context: context,
                ),
                const SizedBox(height: 10),
                _buildEditableTextField(
                  controller: _lastNameController,
                  label: AppLocalizations.of(context)?.lastName ?? 'Last Name',
                  context: context,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: Text(AppLocalizations.of(context)?.saveChanges ??
                          'Save Changes'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          // Optionally reset the controllers to their initial state
                        });
                      },
                      child: Text(
                          AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                    ),
                  ],
                ),
              ],
              _buildLanguageToggleButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildLogoutButton(),
    );
  }

  Widget _buildEditableTextField(
      {required TextEditingController controller,
      required String label,
      required BuildContext context}) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      onChanged: (value) {
        // Optionally handle changes
      },
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _uploadProfilePicture,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _profilePicUrl != null
                ? NetworkImage(_profilePicUrl!)
                : const AssetImage('assets/placeholder-image.jpeg')
                    as ImageProvider,
            backgroundColor: Colors.grey.shade200,
          ),
          const Icon(Icons.camera_alt, color: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
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
    );
  }

  Widget _buildLanguageToggleButton() {
    return ElevatedButton(
      onPressed: () => _toggleLanguage(context),
      child: Text(AppLocalizations.of(context)?.language ?? 'Language / اللغة'),
    );
  }
}
