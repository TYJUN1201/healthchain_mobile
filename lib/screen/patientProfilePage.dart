import 'package:flutter/material.dart';
import 'pdfViewerPage.dart';
import 'patientInfoForm.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:desnet/services/smartcontract/storageContract.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({Key? key}) : super(key: key);

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class UserFile {
  final String ipfsHash;
  String? fileType; // Added property for file type

  UserFile({required this.ipfsHash, this.fileType});
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  StorageContract storageContract = StorageContract(
    "0xDB5332457aed22aB904212c2B8b40C18e6937440",
    "http://10.0.2.2:8545",
  );

  final String userMetamaskAddress = "0x218164Ba1BdDBABB4867EbFd8e29e9c7642a5621";
  List<UserFile> allFiles = [];

  @override
  void initState() {
    super.initState();
    // Call the getAllFiles function when the screen initializes
    fetchCID();
  }

  Future<void> fetchCID() async {
    try {
      List<UserFile> result =
      await storageContract.callContractFunction(userMetamaskAddress, "getAll");

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
            'Failed to fetch file for CID $cid. Status code: ${response
                .statusCode}');
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
              fetchCID();
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
              List<UserFile> filteredFiles = allFiles.where((file) =>
              file.fileType == 'PDF').toList();
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
              List<UserFile> filteredFiles = allFiles.where((file) =>
              file.fileType == 'JSON').toList();
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
                      builder: (context) =>
                          PdfViewerPage(
                            pdfUrl:
                            'http://gateway.pinata.cloud/ipfs/${fileInfo.ipfsHash}',//'http://10.0.2.2:8081/ipfs/${fileInfo.ipfsHash}',
                          ),
                    ),
                  );
                } else if (fileType == 'JSON') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PatientInfoPage(
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
