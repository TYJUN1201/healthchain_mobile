import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthchain/constants/firestore_constants.dart';
import 'package:healthchain/constants/user_constants.dart';

class ChatHomeProvider {
  final FirebaseFirestore firebaseFirestore;

  ChatHomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserDataFirestore(
      String collectionPath, int limit, String? idSearch) {
    return firebaseFirestore
        .collection(collectionPath)
        .limit(limit)
        .where(FirestoreConstants.id, isEqualTo: idSearch)
        .get();
  }

  Stream<QuerySnapshot> getStreamFireStore(
      String pathCollection, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .where(FirestoreConstants.name, isGreaterThanOrEqualTo: textSearch)
          .where(FirestoreConstants.name, isLessThan: '${textSearch}z')
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .snapshots();
    }
  }
}
