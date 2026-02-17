import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class User {
  String username;
  String name;
  String sureName;
  String email;
  dynamic loginTime ;

  User({required this.username, required this.name, required this.sureName, required this.email}){
    loginTime = DateTime.now();
  }

  static Future<User> createUser(String uID) async{
    DatabaseService databaseService = DatabaseService();
    DocumentSnapshot doc = await databaseService.getUserFuture(uID);
    final data = doc.data() as Map<String, dynamic> ;
    return User(username: data['user_name'], name: data['first_name'], sureName: data['sur_name'], email: data['email']);
  }
}