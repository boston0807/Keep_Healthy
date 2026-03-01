import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class User {
  String username;
  String name;
  String surName;
  String email;
  double weight;
  dynamic loginTime;
  String? imageUrl;

  User({required this.username, required this.name, required this.surName, required this.email, this.imageUrl, required this.weight}){
    loginTime = DateTime.now();
  }

  static Future<User> createUser(String uID) async{
    DatabaseService databaseService = DatabaseService();
    DocumentSnapshot doc = await databaseService.getUserFuture(uID);
    final data = doc.data() as Map<String, dynamic> ;
    return User(username: data['user_name'], name: data['first_name'], surName: data['sur_name'], email: data['email'], imageUrl: data['image_url'], weight: data['weight']);
  }

}