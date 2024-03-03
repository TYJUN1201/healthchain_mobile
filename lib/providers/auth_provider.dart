import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthchain/constants/constants.dart';
import 'package:healthchain/models/chat/models.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseFirestore,
  });

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedInWithGoogle = await googleSignIn.isSignedIn();
    bool isLoggedInWithEmail =
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true;

    return isLoggedInWithGoogle || isLoggedInWithEmail;
  }

  Future<String?> handleGoogleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        const storage = FlutterSecureStorage();
        String fcmToken = await storage.read(key: "fcmToken") ?? "";
        updateUserField(firebaseUser.uid, fcmToken);
        print('fcmToken: $fcmToken');
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isEmpty) {
          // Writing data to server because here is a new user
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.name: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });

          // Write data to local storage
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.name, currentUser.displayName ?? "");
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        } else {
          // Already sign up, just get data from firestore
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          // Write data to local
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.name, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
        }

        _status = Status.authenticated;
        notifyListeners();
        return await firebaseUser.getIdToken(true);
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return null;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return null;
    }
  }

  Future<bool> handleEmailSignIn(String email, String password) async {
    _status = Status.authenticating;
    notifyListeners();
    try {
      User? firebaseUser = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      print("email is: $email");
      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.email, isEqualTo: email)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isEmpty) {
          // New user
          print('empty document');
        } else {
          // Already sign up, just get data from firestore
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          const storage = FlutterSecureStorage();
          String fcmToken = await storage.read(key: "fcmToken") ?? "";
          updateUserField(userChat.id, fcmToken);
          await prefs.setString(FirestoreConstants.name, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
          await prefs.setString(FirestoreConstants.type, userChat.type);
          print('user role:${userChat.type}');
        }
      }
      print('printing SharedPreferences prefs');
      Set<String> keys = prefs.getKeys();

      // Print out each key-value pair
      for (String key in keys) {
        print('$key: ${prefs.get(key)}');
      }

      _status = Status.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
  }

  void handleException() {
    _status = Status.authenticateException;
    notifyListeners();
  }

  Future<void> handleSignOut() async {
    try {
      bool isLoggedIn = await googleSignIn.isSignedIn();
      await firebaseAuth.signOut();
      String userId = prefs.getString(FirestoreConstants.id) ?? "";
      if (userId.isNotEmpty) deleteUserField(userId, "fcmToken");
      await prefs.clear();
      if (isLoggedIn) {
        // Google sign out
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }
      print('Sign out successfully.');
    } catch (e) {
      print('Error when sign out:$e');
    }
    await Web3AuthFlutter.logout();
    _status = Status.uninitialized;
  }

  Future<void> deleteUserField(String userId, String fieldToDelete) async {
    try {
      FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()}).whenComplete(
              () => print("successful delete fcmToken"));
    } catch (e) {
      print('Error deleting field: $e');
    }
  }

  Future<void> updateUserField(String userId, String fcmToken) async {
    print("userId: $userId fcmToken: $fcmToken");
    try {
      FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .doc(userId)
          .update({'fcmToken': fcmToken}).whenComplete(
              () => print("successful update fcmToken"));
    } catch (e) {
      print('Error update field: $e');
    }
  }
}
