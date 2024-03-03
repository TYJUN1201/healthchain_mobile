import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthchain/services/IPFS/ipfsService.dart';
import 'package:pinenacl/api/authenticated_encryption.dart';
import 'package:healthchain/providers/auth_provider.dart' as AuthProv;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthchain/constants/constants.dart';
import 'package:healthchain/models/ipfs_file.dart';
import 'package:healthchain/services/smartcontract/storageContract.dart';
import 'package:web3dart/web3dart.dart';
import '../../widgets/confirmation.dart';
import '../authentication/sign_in.dart';
import '../chat/settings_page.dart';
import '../files/allFilesPage.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userMetamaskAddress = '';
  List<IPFSFile> allFiles = [];
  late final AuthProv.AuthProvider authProvider =
      context.read<AuthProv.AuthProvider>();
  String userName = '';
  String imgUrl = '';

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignIn()));
  }

  @override
  void initState() {
    fetchUserInfo();
    fetchCID();
    super.initState();
  }

  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString(FirestoreConstants.name).toString() ?? '';
      imgUrl = prefs.getString(FirestoreConstants.photoUrl) ?? '';
    });
  }

  Future<void> fetchCID() async {
    try {
      // Create StorageContract object and initialize
      StorageContract storageContract = StorageContract();

      // Get public address from private key
      final prefs = await SharedPreferences.getInstance();
      final privateKey = prefs.getString('privateKey') ?? '0';
      final credentials = EthPrivateKey.fromHex(privateKey);
      final senderAddress = credentials.address;
      print(senderAddress);
      // Fetch CIDs from BlockChain
      List<IPFSFile> files = [];
      List<dynamic> result = await storageContract
          .callContractFunction(senderAddress, "getAll", []);

      int i = 0;
      for (var fileDataList in result[0]) {
        i++;
        if (fileDataList is List<dynamic> && fileDataList.isNotEmpty) {
          String ipfsCID = fileDataList[0].toString();

          //Fetch file from IPFS
          IPFSFile tempIPFSFile = await IPFSService.getIPFSFile(ipfsCID);
          files.add(tempIPFSFile);
        }
      }
      setState(() {
        allFiles = files;
      });
    } catch (e) {
      print("Error loading files: $e");
    }
  }

  // Generate QR code (id, public key)
  Future<void> _showShareDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString(FirestoreConstants.privateKey) ?? '0';
    final credentials = EthPrivateKey.fromHex(privateKey);
    final publicKey =
        base64Encode(PrivateKey(credentials.privateKey).publicKey);
    final userId = prefs.getString(FirestoreConstants.id) ?? '0';
    String jsonString = '{"peerId":"$userId", "peerPublicKey":"$publicKey"}';
    print('qr json string:$jsonString');

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quick Share QR code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 200.0, // Set a specific width
                height: 200.0, // Set a specific height
                child: QrImageView(
                  data: jsonString,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Share QR to quick share'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(164, 187, 181, 1.0),
        body: Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: 140,
                child: Stack(
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(0, 0),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                imgUrl.isEmpty
                                    ? 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60'
                                    : imgUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 12),
                child: Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 32),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 12),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: const AlignmentDirectional(0, 0),
                              child: IconButton(
                                icon: const Icon(Icons.file_copy_outlined),
                                iconSize: 40,
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FilesPage(
                                          files: allFiles
                                              .where((ipfsFile) =>
                                                  ipfsFile.fileType == 'JSON')
                                              .toList()),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const Text(
                            'EMRs',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 12),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                alignment: const AlignmentDirectional(0, 0),
                                child: IconButton(
                                  icon:
                                      const Icon(Icons.picture_as_pdf_rounded),
                                  iconSize: 40,
                                  onPressed: () async {
                                    //fetchCID();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FilesPage(
                                            files: allFiles
                                                .where((ipfsFile) =>
                                                    ipfsFile.fileType == 'PDF')
                                                .toList()),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Text(
                              'PDFs',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 12),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: const AlignmentDirectional(0, 0),
                              child: IconButton(
                                icon: const Icon(Icons.qr_code),
                                iconSize: 40,
                                onPressed: () async {
                                  _showShareDialog(context);
                                },
                              ),
                            ),
                          ),
                          const Text(
                            'Quick Share',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(0, -1),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsPage()));
                                },
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 8, 16, 8),
                                        child: Icon(
                                          Icons.edit,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 0, 12, 0),
                                          child: Text(
                                            'Edit Profile',
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  bool? confirm =
                                      await Confirmation.showConfirmationDialog(
                                          context,
                                          'Log out',
                                          const Text(
                                              'Are you sure you want to log out?'));
                                  if (confirm!) {
                                    handleSignOut();
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 8, 16, 8),
                                        child: Icon(
                                          Icons.login_rounded,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 0, 12, 0),
                                          child: Text(
                                            'Log out',
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
