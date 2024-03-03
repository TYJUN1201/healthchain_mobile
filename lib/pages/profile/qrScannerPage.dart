import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/api/authenticated_encryption.dart' as nacl;
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/credentials.dart';
import '../../constants/firestore_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_home_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/cryptography/box_encryption.dart';
import '../../widgets/confirmation.dart';
import '../chat/chat_page.dart';

class QRScannerPage extends StatelessWidget {
  final String ipfsCID;
  final String aesSecretKey;

  const QRScannerPage(
      {super.key, required this.ipfsCID, required this.aesSecretKey});

  @override
  Widget build(BuildContext context) {
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: (controller) => _onQRViewCreated(controller, context),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    late final AuthProvider authProvider = context.read<AuthProvider>();
    late final ChatProvider chatProvider = context.read<ChatProvider>();
    late final ChatHomeProvider chatHomeProvider = context.read<
        ChatHomeProvider>();
    String userName = '';
    String userUrl = '';
    bool shouldPopNavigator = false;

    controller.scannedDataStream.listen((scanData) async {
      if (!shouldPopNavigator) {
        String? qrCodeValue = scanData?.code;
        print('Scanned QR code: $qrCodeValue');
        dynamic qrDetails = jsonDecode(qrCodeValue!);

        if (qrDetails['peerId']!.isNotEmpty &&
            qrDetails['peerPublicKey']!.isNotEmpty) {
          controller.stopCamera();
          final String peerId = qrDetails['peerId'];

          Future<QuerySnapshot<Map<String, dynamic>>> userData =
          chatHomeProvider.getUserDataFirestore(
              FirestoreConstants.pathUserCollection, 1, peerId);
          QuerySnapshot<Map<String, dynamic>> querySnapshot = await userData;

          for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
          in querySnapshot.docs) {
            Map<String, dynamic> data = documentSnapshot.data();
            userName = data[FirestoreConstants.name];
            userUrl = data[FirestoreConstants.photoUrl];
          }
          bool? confirm = await Confirmation.showConfirmationDialog(
            context,
            'Confirmation for sharing file',
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 200.0,
                    ),
                    child: Image.network(
                      userUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Are you sure to share the file with this user?',
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                  ),
                ],
              ),
            ),
          );
          print(confirm);
          if (confirm!) {
            print('hi');
            String currentUserId = '';

            // Create unique groupChatId
            String groupChatId = '';
            if (authProvider
                .getUserFirebaseId()
                ?.isNotEmpty == true) {
              currentUserId = authProvider.getUserFirebaseId()!;
            }
            if (currentUserId.compareTo(peerId!) > 0) {
              groupChatId = '$currentUserId-$peerId';
            } else {
              groupChatId = '$peerId-$currentUserId';
            }

            // Box Encryption: Use peer's private key to encrypt current file's AES Secret Key
            final prefs = await SharedPreferences.getInstance();
            final privateKey =
                prefs.getString(FirestoreConstants.privateKey) ?? '0';
            final credentials = EthPrivateKey.fromHex(privateKey);
            print(base64Encode(PrivateKey(credentials.privateKey).publicKey));

            // Use peer's public key to encrypt
            final peerPublicKey = qrDetails['peerPublicKey'];
            List<dynamic> boxResult = await BoxEncryption.encryptMessage(
              aesSecretKey,
              nacl.PublicKey(base64Decode(peerPublicKey!)),
            );
            nacl.EncryptedMessage encryptedAesSecretKey = boxResult[0];
            nacl.PublicKey ephemeralPublicKey = boxResult[1];

            // Put all info needed for decryption and send to peer in chat
            Map<String, dynamic> fileData = {
              'fileCID': ipfsCID,
              'encryptedAesSecretKey': {
                'version': 'x25519-xsalsa20-poly1305',
                'nonce': base64Encode(encryptedAesSecretKey.nonce),
                'ephemPublicKey': base64Encode(ephemeralPublicKey.asTypedList),
                'ciphertext': base64Encode(encryptedAesSecretKey.cipherText),
              },
            };
            chatProvider.sendMessage(
               jsonEncode(fileData), 3, groupChatId, currentUserId, peerId);
            // Navigate to chat with groupChatId
            shouldPopNavigator = true;
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatPage(
                      arguments: ChatPageArguments(
                        peerId: peerId,
                        peerAvatar: userUrl,
                        peerNickname: userName,
                      ),
                    ),
              ),
            );
          }
        }
      }
    });
  }
}
