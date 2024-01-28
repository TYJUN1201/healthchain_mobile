import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:desnet/services/cryptography/box_encryption.dart';

// AES Algorithms
class AESEncryption {
  // AES-CBC with 256 bit keys and HMAC-SHA256 authentication.
  final algorithm = AesCbc.with256bits(
    macAlgorithm: Hmac.sha256(),
  );

  late SecretBox secretBox;
  @override
  String toString() {
    return "{'Ciphertext':'${secretBox.cipherText}','Nonce':'${secretBox.nonce}','MAC':'${secretBox.mac.bytes}'}";
  }

  Future<String> encryptAES(String message) async {
    // Generate secret key
    final secretKey = await algorithm.newSecretKey();

    // Encrypt
    secretBox = await algorithm.encrypt(
      message.codeUnits,
      secretKey: secretKey,
    );

    // print('Nonce: ${secretBox.nonce}');
    // print('Ciphertext: ${secretBox.cipherText}');
    // print('MAC: ${secretBox.mac.bytes}');

    return BoxEncryption.encryptSecretKey(await secretKey.extractBytes());
  }

  Future<String> decryptAES(SecretBox secretBox, String encryptedSecretKey) async {
    // Call Metamask API: eth_decrypt(encryptedMessage, address)
    String decryptedSecretKeyBytesList = '';

    // Decrypt
    final decryptedBytes = await algorithm.decrypt(
      secretBox,
      secretKey: SecretKey(utf8.encode(decryptedSecretKeyBytesList)), // Convert String to SecretKey
    );

    return utf8.decode(decryptedBytes); // return AES Key
  }


}