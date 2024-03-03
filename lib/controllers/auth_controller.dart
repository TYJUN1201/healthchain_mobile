import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthchain/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;

  Future<Map<String, dynamic>> signUp(String email, String password, String name, String type) async {
    const storage = FlutterSecureStorage();
    String? fcmToken = await storage.read(key: "fcmToken");
    print("fcm token : $fcmToken");
    Map<String, dynamic> response = {
      "status": null,
      "data": null,
      "message": null,
    };
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      response["status"] = 200;
      response["data"] = await SystemUser(name: name, email: email, type: type, fcmToken: fcmToken).createUser();
      response["message"] = "sign up successfully";
    } on FirebaseAuthException catch (e) {
      response["status"] = 500;
      response["message"] = e.message;
    }
    return response;
  }

  resetPassword(String email) async {
    Map<String, dynamic> response = {
      "status": null,
      "data": null,
      "message": null,
    };
    try {
      await _auth.sendPasswordResetEmail(email: email);
      response["status"] = 200;
      response["data"] = "";
      response["message"] = "Reset password email have been sent";
      return response;
    } on FirebaseAuthException catch (e) {
      response["status"] = 500;
      response["message"] = e.message;
      return response;
    }
  }
}
