import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthchain/constants/constants.dart';

class UserChat {
  final String id;
  final String photoUrl;
  final String nickname;
  final String aboutMe;
  final String type;

  const UserChat({required this.id, required this.photoUrl, required this.nickname, required this.aboutMe, required this.type});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.name: nickname,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.type: type,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    String type = "";
    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.name);
    } catch (e) {}
    try {
      type = doc.get(FirestoreConstants.type);
    } catch (e) {}
    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
      type: type,
    );
  }
}
