import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthchain/constants/constants.dart';
import 'package:healthchain/models/chat/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider({required this.firebaseFirestore, required this.prefs, required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<String> getReceiverFCMToken(String receiverId) async {
    String token = "";
    print(receiverId);
    final QuerySnapshot result = await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .where(FirestoreConstants.id, isEqualTo: receiverId)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if(documents.isNotEmpty){
      DocumentSnapshot documentSnapshot = documents[0];
      Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
      token = userData['fcmToken'] ?? "";
    }
    return token;
  }

  Future<void> sendMessage(String content, int type, String groupChatId, String currentUserId, String peerId) async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );
    // get user FCM token
    final fcmToken = await getReceiverFCMToken(peerId);
    if(fcmToken.isNotEmpty){
      sendNotification(fcmToken, content);
    }
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }

  Future<void> sendNotification(String receiverFCMToken, String body) async {
    String? cloudFunctionEndpoint = dotenv.env['CLOUD_FUNCTION_ENDPOINT'];
    String? apiKey = dotenv.env['MESSAGING_API_KEY'] ?? "";

    try {
      Map<String, String> notificationBody = {
        "title": prefs.get(FirestoreConstants.name).toString() ?? "",
        "body": body,
        "time": DateTime.now().millisecondsSinceEpoch.toString(),
      };
      print(jsonDecode(jsonEncode(notificationBody)));
      final response = await http.post(
        Uri.parse(cloudFunctionEndpoint!),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': apiKey,
        },
        body: jsonEncode(<String, dynamic>{
          'notification': jsonDecode(jsonEncode(notificationBody)),
          'to': receiverFCMToken
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent');
      } else {
        print(response.body);
        print('Failed to send notification');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}


class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
  static const file = 3;
}
