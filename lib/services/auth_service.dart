import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keep_healthy/services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService db = DatabaseService();

  Future<UserCredential> login(String email, String password) async{
    return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
  }

  Future<UserCredential> register(String contact, String username, String firstName, String surName, String password, String passwordConfirm) async {
    if (password != passwordConfirm){
      throw Exception("Password confirm is incorrect");
    }
    else {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: contact, password: password);
      await saveUserInfo(contact, username, firstName, surName, userCredential.user!.uid);
      return userCredential;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> saveUserInfo(String contact, String username, String firstName, String surName, String uID){
    return db.user.doc(uID).set({
      'user_name': username,
      'first_name': firstName,
      'sur_name': surName,
      'email': contact
    });
  }
}
