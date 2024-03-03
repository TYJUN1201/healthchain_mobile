import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pinenacl/x25519.dart' as nacl;
import 'package:pinenacl/api/authenticated_encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthchain/services/IPFS/ipfsService.dart';
import 'dart:convert';
import 'dart:io';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';
import 'package:healthchain/constants/constants.dart';
import '../../services/cryptography/aes_algorithm.dart';
import '../../services/cryptography/box_encryption.dart';
import '../../widgets/confirmation.dart';
import 'createEMRPage.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({
    super.key,
  });

  @override
  _UploadFilePageState createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  TextEditingController senderAddressController = TextEditingController();
  String userMetamaskAddress = '';
  Uint8List? _pdfData;
  String? _fileName;
  Key? _pdfViewKey; // Add a Key variable

  @override
  void initState() {
    super.initState();
    _pdfViewKey = UniqueKey(); // Initialize the Key
  }

  Future<void> _selectPdfFile() async {
    try {
      final filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
        final filePath = filePickerResult.files.first.path;
        final pdfBytes = await File(filePath!).readAsBytes();

        setState(() {
          _pdfData = pdfBytes;
          _fileName = filePickerResult.files.first.name;
          _pdfViewKey = UniqueKey(); // Update the Key
        });
        print(_pdfData);
        print('file name: $_fileName');
      }
    } catch (error) {
      print('Error selecting PDF file: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              if (_pdfData != null)
                SizedBox(
                  height: 350,
                  child: PDFView(
                    key: _pdfViewKey,
                    pdfData: _pdfData,
                    autoSpacing: true,
                    pageSnap: true,
                    swipeHorizontal: true,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _selectPdfFile();
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        StyleConstants.linear8,
                      ),
                    ),
                  ),
                ),
                child: const Text(
                  'Select PDF File',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EMRInputScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        StyleConstants.linear8,
                      ),
                    ),
                  ),
                ),
                child: const Text(
                  'Create EMR',
                ),
              ),
              const SizedBox(height: 20),
              if (_pdfData != null)
                ElevatedButton(
                  onPressed: () async {
                    bool? confirmed = await Confirmation.showConfirmationDialog(
                      context,
                      'Upload File',
                      const Text('Are you sure you want to upload this file?'),
                    );
                    if (confirmed ?? false) {
                      // Step 1: AES Encryption
                      List<dynamic> aesResult = await AESEncryption.encryptAES(
                          base64Encode(_pdfData!));
                      String encryptedFile = aesResult[0];
                      String aesSecretKey = aesResult[1];

                      // Testing 1: AES decrypt result of encryption
                      // assert(utf8.decode(_pdfData!) ==
                      //     await AESEncryption.decryptAES(
                      //         jsonDecode(encryptedFile),
                      //         base64Decode(aesSecretKey)));

                      // Step 2: Box Encryption
                      final prefs = await SharedPreferences.getInstance();
                      final privateKey =
                          prefs.getString(FirestoreConstants.privateKey) ?? '0';
                      final credentials = EthPrivateKey.fromHex(privateKey);
                      List<dynamic> boxResult =
                          await BoxEncryption.encryptMessage(aesSecretKey,
                              PrivateKey(credentials.privateKey).publicKey);
                      nacl.EncryptedMessage encryptedAesSecretKey =
                          boxResult[0];
                      nacl.PublicKey ephemeralPublicKey = boxResult[1];

                      // Testing 2: Box decrypt result of encryption
                      assert(aesSecretKey ==
                          await BoxEncryption.decryptMessage(
                              base64Encode(encryptedAesSecretKey.cipherText),
                              base64Encode(encryptedAesSecretKey.nonce),
                              base64Encode(
                                  nacl.PrivateKey(credentials.privateKey)),
                              base64Encode(ephemeralPublicKey)));

                      // Step 3: Storing on IPFS
                      Map<String, dynamic> ipfsData = {
                        'fileType': 'PDF',
                        'fileName': _fileName,
                        'encryptedFile': encryptedFile,
                        'encryptedAesSecretKey': {
                          'version': 'x25519-xsalsa20-poly1305',
                          'nonce': base64Encode(encryptedAesSecretKey.nonce),
                          'ephemPublicKey':
                              base64Encode(ephemeralPublicKey.asTypedList),
                          'ciphertext':
                              base64Encode(encryptedAesSecretKey.cipherText),
                        },
                      };

                      // Testing 3: Fully decryption process
                      assert(utf8.decode(_pdfData!) ==
                          await AESEncryption.decryptAES(
                              ipfsData['encryptedFile'],
                              base64Decode(await BoxEncryption.decryptMessage(
                                  ipfsData['encryptedAesSecretKey']
                                      ['ciphertext'],
                                  ipfsData['encryptedAesSecretKey']['nonce'],
                                  base64Encode(
                                      nacl.PrivateKey(credentials.privateKey)),
                                  ipfsData['encryptedAesSecretKey']
                                      ['ephemPublicKey']))));

                      final String cid =
                          await IPFSService.pinFileToIPFS(ipfsData);
                      print(cid);
                      // Step 4: Store CID on blockchain
                      print(await IPFSService.uploadToBlockChain(cid));
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          StyleConstants.linear8,
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Upload PDF File',
                  ),
                  // Implement the logic to upload the file to IPFS using senderAddress
                ),
            ],
          ),
        ),
      ),
    );
  }
}
