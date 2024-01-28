import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pinenacl/api/authenticated_encryption.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/x25519.dart';

class BoxEncryption {
   static Future<String> encryptSecretKey(List<int> secretKeyBytesList) async {
    final keyPair = PrivateKey.generate();
    final ephemeralPublicKey = keyPair.publicKey;

    final metamaskPublicKey = PublicKey(base64.decode('7vGRD6KCJ4E8x3huE6bfMMoTLbJr4KQsCIf4k35a5Es='));

    final box = Box(myPrivateKey: keyPair, theirPublicKey: metamaskPublicKey);

    final encrypted = box.encrypt((Uint8List.fromList(secretKeyBytesList)));

    final result = {
      "version": "x25519-xsalsa20-poly1305",
      "nonce": base64.encode(encrypted.nonce),
      "ephemPublicKey": base64.encode(ephemeralPublicKey.asTypedList),
      "ciphertext": base64.encode(encrypted.cipherText),
    };

    String utf8String = jsonEncode(result);
    String hexString = hex.encode(utf8.encode(utf8String));
    return '0x$hexString';
  }

}