import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data' as type;
import 'package:convert/convert.dart';
import 'package:pinenacl/api/authenticated_encryption.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/x25519.dart';

import 'package:pointycastle/pointycastle.dart' as castle;


class BoxEncryption {
   static Future<List<dynamic>> encryptMessage(String message, PublicKey alicePublicKey) async {
     // Bob generate temporarily key pair
     final ephemeralPrivateKey = PrivateKey.generate();
     // Generate public key using private key
     final ephemeralPublicKey = ephemeralPrivateKey.publicKey;
     // Bob using his temporarily private key and Alice's public key to encrypt message
     final box = Box(myPrivateKey: ephemeralPrivateKey, theirPublicKey: alicePublicKey);
     final encryptedBox = box.encrypt(Uint8List.fromList(message.codeUnits));

     final result = {
       "version": "x25519-xsalsa20-poly1305",
       "nonce": base64.encode(encryptedBox.nonce),
       "ephemPublicKey": base64.encode(ephemeralPublicKey.asTypedList),
       "ciphertext": base64.encode(encryptedBox.cipherText),
     };

     String utf8String = jsonEncode(result);
     // print(utf8String);
     String hexString = hex.encode(utf8.encode(utf8String));
     print('Encrypted Message: 0x$hexString');

     return [encryptedBox, ephemeralPublicKey];
   }

   static Future<String> decryptMessage(String cipherText, String nonce, String alicePrivateKey, String bobEphemeralPublicKey) async {
     final box = Box(myPrivateKey: PrivateKey(base64Decode(alicePrivateKey)), theirPublicKey: PublicKey(base64Decode(bobEphemeralPublicKey)));
     final decrypted = box.decrypt(ByteList(base64Decode(cipherText)), nonce: Uint8List.fromList(base64Decode(nonce)));

     String decryptedMessage = utf8.decode(decrypted);
     // print('Decrypted Message: $decryptedMessage');

     return decryptedMessage;
   }
}