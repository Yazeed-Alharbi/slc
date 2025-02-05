import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  
  // get users collection
  final CollectionReference users = FirebaseFirestore.instance.collection('users');


  // Sign in: add a new user.
  Future<void> addNewUser(String userName, String name, String password,String email, String profilePic){
    return users.add({
      'username': userName,
      'email': email,
      'name': name,
      'profilePicture': null, // To be done! #TODO
      'createdDate': Timestamp.now(),
      'lastLoginDate': Timestamp.now(),
      'passwordHash': password // For now plain to test
    });
  }
  
}