import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:healthchain/models/ipfs_file.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:healthchain/pages/profile/qrScannerPage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinenacl/api/authenticated_encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/credentials.dart';

import '../../constants/firestore_constants.dart';
import '../../services/cryptography/aes_algorithm.dart';
import '../../services/cryptography/box_encryption.dart';

class viewFilePage extends StatefulWidget {
  final IPFSFile ipfsFile;

  viewFilePage({required this.ipfsFile});

  @override
  _viewFilePageState createState() => _viewFilePageState();
}

class _viewFilePageState extends State<viewFilePage> {
  dynamic fileData = {};
  String fileAesKey = '';
  bool isLoading = false;
  late String pdfPath;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      setState(() {
        isLoading = true;
      });

      final file = await _decryptFile();

      if (widget.ipfsFile.fileType == 'JSON') {
        setState(() {
          fileAesKey = file[0];
          fileData = file[1];
        });
      } else if (widget.ipfsFile.fileType == 'PDF') {
        final filename = basename(widget.ipfsFile.fileName!);
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$filename';

        await File(filePath).writeAsBytes(base64.decode(file[1]));

        setState(() {
          fileAesKey = file[0];
          fileData = filePath;
        });
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  // Decryption
  Future<List<dynamic>> _decryptFile() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString(FirestoreConstants.privateKey) ?? '0';
    final credentials = EthPrivateKey.fromHex(privateKey);
    final aesSecretKey = await BoxEncryption.decryptMessage(
        widget.ipfsFile.encryptedAesSecretKey?['ciphertext'],
        widget.ipfsFile.encryptedAesSecretKey?['nonce'],
        base64Encode(PrivateKey(credentials.privateKey)),
        widget.ipfsFile.encryptedAesSecretKey?['ephemPublicKey']);
    final file = await AESEncryption.decryptAES(
        widget.ipfsFile.encryptedFile,
        base64Decode(aesSecretKey));
    return [aesSecretKey, file];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ipfsFile.fileName!),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScannerPage(ipfsCID: widget.ipfsFile.ipfsCID, aesSecretKey: fileAesKey),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fileData == null
              ? const Center(child: Text('No data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [showFile(fileData)],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget showFile(dynamic data) {
    if (widget.ipfsFile.fileType == 'JSON') {
      return Column(
        children: _buildFormFields(data),
      );
    } else if (widget.ipfsFile.fileType == 'PDF') {
      return SizedBox(
        height: 400, // Set a fixed height or adjust as needed
        child: PDFView(filePath: data),
      );
    } else {
      return const Text('Unsupported file type');
    }
  }

  List<Widget> _buildFormFields(Map<String, dynamic> data) {
    List<Widget> formFields = [];

    data.forEach((key, value) {
      formFields.add(const SizedBox(height: 5));
      formFields.add(_buildTextField(key, value));
    });

    return formFields;
  }

  Widget _buildTextField(String label, String value) {
    return TextFormField(
      readOnly: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
