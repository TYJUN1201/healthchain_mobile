import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

// AES Algorithms
class AESEncryption {
  // AES-CBC with 256 bit keys and HMAC-SHA256 authentication.
  static final algorithm = AesCbc.with256bits(
    macAlgorithm: Hmac.sha256(),
  );

  static Future<List<dynamic>> encryptAES(String message) async {
    // Generate random secret key
    final secretKey = await algorithm.newSecretKey();

    // Encrypt
    SecretBox secretBox = await algorithm.encrypt(
      message.codeUnits,
      secretKey: secretKey,
    );

    // print('AES encryption');
    // print('Nonce: ${base64Encode(secretBox.nonce)}');
    // print('Ciphertext: ${base64Encode(secretBox.cipherText)}');
    // print('MAC: ${base64Encode(secretBox.mac.bytes)}');
    // print('AES secret key: ${base64Encode(await secretKey.extractBytes())}');

    return ['{"Ciphertext":"${base64Encode(secretBox.cipherText)}","Nonce":"${base64Encode(secretBox.nonce)}","MAC":"${base64Encode(secretBox.mac.bytes)}"}', base64Encode(await secretKey.extractBytes())];
  }

  static Future<String> decryptAES(Map<dynamic, dynamic>? secretBoxJson, List<int> secretKey) async {
    // Convert JSON String to SecretBox
    SecretBox secretBox = SecretBox(
      Uint8List.fromList(base64Decode(secretBoxJson?['Ciphertext'] ?? '')),
      nonce: Uint8List.fromList(base64Decode(secretBoxJson?['Nonce'] ?? '')),
      mac: Mac(base64Decode(secretBoxJson?['MAC'] ?? '')),
    );

    print(base64Encode(secretBox.cipherText));
    print(secretBox.nonce);
    print(secretBox.mac);
    // Decrypt
    final decryptedBytes = await algorithm.decrypt(
      secretBox,
      secretKey: SecretKey(secretKey),
    );
    return utf8.decode(decryptedBytes);
  }
}