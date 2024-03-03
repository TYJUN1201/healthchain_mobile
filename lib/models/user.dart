import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:healthchain/constants/constants.dart';
import 'package:healthchain/constants/user_constants.dart';

class SystemUser {
  final String? id;
  final String? name;
  final String? email;
  final String? type;
  final String? phoneNumber;
  final String? address;
  final String? fcmToken;
  final String? createdAt;
  final String? updatedAt;

  SystemUser(
      {this.id,
      required this.email,
      this.name,
      required this.type,
      this.phoneNumber,
      this.address,
      this.fcmToken,
      this.createdAt,
      this.updatedAt});

  SystemUser.empty(
      {this.id,
      this.name,
      this.email,
      this.type,
      this.phoneNumber,
      this.address,
      this.fcmToken,
      this.createdAt,
      this.updatedAt});

  factory SystemUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return SystemUser(
        id: snapshot.id,
        name: data?['nickname'],
        email: data?['email'],
        type: data?['type'],
        phoneNumber: data?['phoneNumber'],
        address: data?['address'],
        fcmToken: data?['fmcToken'],
        createdAt: data?["createdAt"],
        updatedAt: data?["updatedAt"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (name != null) "nickname": name,
      if (email != null) "email": email,
      if (type != null) "type": type,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
      if (address != null) "address": address,
      if (fcmToken != null) "fcmToken": fcmToken,
      "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
      "updatedAt": DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  final docRef = FirebaseFirestore.instance.collection("users").withConverter(
        fromFirestore: SystemUser.fromFirestore,
        toFirestore: (SystemUser user, options) => user.toFirestore(),
      );

  final docRefWithoutConverter = FirebaseFirestore.instance.collection("users");

  Future<Map<String, dynamic>> createUser() async {
    Map<String, dynamic> mapUser = {};
    var newUser = docRefWithoutConverter.add(toFirestore());
    await newUser.then((documentSnapshot) => {
          docRefWithoutConverter.doc(documentSnapshot.id).update({
            UserConstants.id: documentSnapshot.id,
            UserConstants.updatedAt:
                DateTime.now().millisecondsSinceEpoch.toString()
          }),
          mapUser.putIfAbsent("id", () => documentSnapshot.id)
        });
    return mapUser;
  }

  void updateUser() async {
    Map<String, dynamic> mapUser = {};
    await docRefWithoutConverter.doc(id).update({
      UserConstants.type: type,
      UserConstants.name: name,
      UserConstants.email: email,
      UserConstants.updatedAt: DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  Future<Map<String, dynamic>> get(String type, String data) async {
    Map<String, dynamic> mapUser = {};

    dynamic getUser;
    if (type == "id") {
      getUser = await docRef.doc(data).get();
      mapUser.putIfAbsent("id", () => getUser.emrData()?.id);
      mapUser.putIfAbsent("nickname", () => getUser.emrData().name);
      mapUser.putIfAbsent("email", () => getUser.emrData().email);
      mapUser.putIfAbsent("type", () => getUser.emrData().type);
      mapUser.putIfAbsent("phoneNumber", () => getUser.emrData().phoneNumber);
      mapUser.putIfAbsent("address", () => getUser.emrData().address);
    } else {
      getUser = docRef.where(type, isEqualTo: data).get();
      await getUser.then((querySnapshot) => {
            for (var docSnapshot in querySnapshot.docs)
              {
                mapUser.putIfAbsent("id", () => docSnapshot.id),
                mapUser.putIfAbsent(
                    "nickname", () => docSnapshot.emrData().name),
                mapUser.putIfAbsent("email", () => docSnapshot.emrData().email),
                mapUser.putIfAbsent("type", () => docSnapshot.emrData().type),
                mapUser.putIfAbsent(
                    "phoneNumber", () => docSnapshot.emrData().phoneNumber),
                mapUser.putIfAbsent(
                    "address", () => docSnapshot.emrData().address),
              }
          });
    }
    return mapUser;
  }
}
