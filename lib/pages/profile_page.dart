import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/utils/namespace_utils.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/web3app.dart';
import '../models/chain_metadata.dart';
import '../utils/crypto/chain_data.dart';
import 'pdfViewerPage.dart';
import 'patientInfoForm.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:desnet/services/smartcontract/storageContract.dart';
import 'package:web3dart/web3dart.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({
    super.key,
    required this.web3App,
  });

  final Web3App web3App;

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class UserFile {
  final String ipfsHash;
  String? fileType; // Added property for file type

  UserFile({required this.ipfsHash, this.fileType});
}

final List<String> namespaceAccounts = [];

class _PatientProfilePageState extends State<PatientProfilePage> {
  Map<String, SessionData> _activeSessions = {};
  SessionData? _sessionData;
  String userMetamaskAddress = '';
  List<UserFile> allFiles = [];

  @override
  void initState() {
    _activeSessions = widget.web3App.getActiveSessions();
    _sessionData = _activeSessions[_activeSessions.keys.toList().first];
    userMetamaskAddress = NamespaceUtils.getAccount(
        _sessionData!.namespaces.values.first.accounts.first);
    userMetamaskAddress == null
        ? fetchCID(userMetamaskAddress)
        : null; // Call the fetchCID function when the screen initializes if having session with metamask
    super.initState();
  }

  Future<void> fetchCID(String address) async {
    try {
      StorageContract storageContract = StorageContract(
        EthereumAddress.fromHex('0xDB5332457aed22aB904212c2B8b40C18e6937440'),
        "http://10.0.2.2:8545",
      );
      List<UserFile> result =
          await storageContract.callContractFunction(address, "getAll");

      // Extract IPFS hashes from the result
      List<String> ipfsHashes = result.map((file) => file.ipfsHash).toList();

      // Fetch file types based on IPFS hashes
      List<String> fileTypes = await getFileTypes(ipfsHashes);

      // Update the state with the retrieved files and their types
      setState(() {
        allFiles = result;
        for (int i = 0; i < allFiles.length; i++) {
          allFiles[i].fileType = fileTypes[i];
        }
      });
    } catch (e) {
      print("Error loading files: $e");
    }
  }

  Future<List<String>> getFileTypes(List<String> ipfsCids) async {
    List<String> fileTypes = [];

    for (String cid in ipfsCids) {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8081/ipfs/$cid'));

      if (response.statusCode == 200) {
        String fileType = determineFileType(response.headers['content-type']);
        fileTypes.add(fileType);
      } else {
        print(
            'Failed to fetch file for CID $cid. Status code: ${response.statusCode}');
      }
    }
    return fileTypes;
  }

  String determineFileType(String? contentType) {
    contentType = contentType?.toLowerCase() ?? '';
    if (contentType.contains('application/json')) {
      return 'JSON';
    } else if (contentType.contains('image')) {
      return 'Image';
    } else if (contentType.contains('text')) {
      return 'Text';
    } else if (contentType.contains('pdf')) {
      return 'PDF';
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Trigger the loadFiles method when the refresh button is pressed
              print('address: $userMetamaskAddress');
              fetchCID(userMetamaskAddress);
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              // Filter the list here
              List<UserFile> filteredFiles =
                  allFiles.where((file) => file.fileType == 'PDF').toList();
              // Navigate to the new page with the filtered list
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FilesListPage(fileType: 'PDF', files: filteredFiles),
                ),
              );
            },
            child: Text('View PDFs'),
          ),
          ElevatedButton(
            onPressed: () {
              List<UserFile> filteredFiles =
                  allFiles.where((file) => file.fileType == 'JSON').toList();
              // Navigate to the new page with the filtered list
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FilesListPage(fileType: 'JSON', files: filteredFiles),
                ),
              );
            },
            child: Text('View EMRs'),
          ),
        ],
      ),
    );
  }
}

class FilesListPage extends StatelessWidget {
  final String fileType;
  List<UserFile> files;

  FilesListPage({required this.fileType, required this.files});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$fileType List'),
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          UserFile fileInfo = files[index];

          return ListTile(
            title: Text('IPFS Hash: ${fileInfo.ipfsHash}'),
            subtitle: Text('File Type: $fileType'),
            trailing: ElevatedButton(
              onPressed: () {
                // Handle button press based on file type
                if (fileType == 'PDF') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewerPage(
                        pdfUrl:
                            'http://gateway.pinata.cloud/ipfs/${fileInfo.ipfsHash}', //'http://10.0.2.2:8081/ipfs/${fileInfo.ipfsHash}',
                      ),
                    ),
                  );
                } else if (fileType == 'JSON') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientInfoPage(
                        jsonUrl:
                            'http://gateway.pinata.cloud/ipfs/${fileInfo.ipfsHash}',
                      ),
                    ),
                  );
                }
              },
              child: Text('View File'),
            ),
          );
        },
      ),
    );
  }
}
