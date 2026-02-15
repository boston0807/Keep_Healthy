import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference user = FirebaseFirestore.instance.collection('user');

  Future<void> addUser(String method, String contact, String username, String firstname, String sureName){
    return user.add({
      'user_name': username,
      'first_name': firstname,
      'sur_name': sureName,
      'email': contact,
    });
    
  }

  Future<DocumentSnapshot> getUserFuture(String uID) async{
    return await user.doc(uID).get();
  }
}