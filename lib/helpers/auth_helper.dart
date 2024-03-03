import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthchain/controllers/auth_controller.dart';
import 'package:healthchain/routes.dart';
import 'package:pinenacl/api/authenticated_encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:healthchain/providers/auth_provider.dart' as AuthProv;
import 'package:web3dart/credentials.dart';

import '../constants/firestore_constants.dart';

class AuthHelper {
  static Future<String> loginWeb3Auth(Future<Web3AuthResponse> Function() method) async {
    try {
      final Web3AuthResponse response = await method();
      print("response: $response");
      print('PrivateKey: ${response.privKey.toString()}');
      print('publickey: ${base64Encode(PrivateKey(EthPrivateKey.fromHex(response.privKey.toString()).privateKey).publicKey)}');

      // Put 'privateKey' into local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('privateKey', response.privKey.toString());
      await prefs.setString('publicKey', base64Encode(PrivateKey(EthPrivateKey.fromHex(response.privKey.toString()).privateKey).publicKey).toString());
      return response.toString();
    } on UserCancelledException {
      log("User cancelled.");
      return "User cancelled";
    } on UnKnownException {
      log("Unknown exception occurred");
      return "Unknown exception occurred";
    } catch (e) {
      log("Unexpected error: $e");
      return "$e"; // Add a return statement here
    }
  }

  static Future<Web3AuthResponse> withEmailJWT(String email, String password) async {
    String idToken = "";
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    idToken = await credential.user?.getIdToken(true) ?? '';
    print('idToken:$idToken');
    return Web3AuthFlutter.login(
      LoginParams(
        loginProvider: Provider.jwt,
        mfaLevel: MFALevel.OPTIONAL,
        extraLoginOptions: ExtraLoginOptions(
          id_token: idToken,
          verifierIdField: "sub",
          domain: 'firebase',
        ),
      ),
    );
  }

  static Future<Web3AuthResponse> withGoogleJWT(String idToken) async {
    print('google idToken$idToken');
    return Web3AuthFlutter.login(
      LoginParams(
        loginProvider: Provider.google,
        mfaLevel: MFALevel.OPTIONAL,
        extraLoginOptions: ExtraLoginOptions(
          id_token: idToken,
          verifierIdField: "sub",
          domain: 'firebase',
        ),
      ),
    );
  }

  static Future<Map<String, dynamic>> registerUser(email, password, name, type, context) async {
    var response = await AuthController().signUp(email, password, name, type);
    var parsedData = await response["data"];
    // Put 'id' into local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(FirestoreConstants.id, parsedData["id"].toString());
    return response;
  }

  resetPassword(email) async {
    return await AuthController().resetPassword(email);
  }
}