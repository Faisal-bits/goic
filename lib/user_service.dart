import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> saveUserInfoToFirestore(
      String userId, String firstName, String lastName, String email) async {
    return _usersCollection
        .doc(userId)
        .set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
        })
        .then((value) => print("User Info Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
