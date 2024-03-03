import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:healthchain/models/ipfs_file.dart';
import 'viewFilePage.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({
    Key? key,
    required this.files,
  }) : super(key: key);

  final List<IPFSFile> files;

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Files List'),
      ),
      body: ListView.builder(
        itemCount: widget.files.length,
        itemBuilder: (context, index) {
          IPFSFile ipfsFile = widget.files[index];
          return ListTile(
            title: Text('${ipfsFile.fileName}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _showConfirmationDialog(context, ipfsFile);
                  },
                  child: const Text('View File'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, IPFSFile ipfsFile) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to perform this action?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('Decrypting...');
                Navigator.of(context).pop();
                _navigateToViewFilePage(ipfsFile);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToViewFilePage(IPFSFile ipfsfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => viewFilePage(ipfsFile: ipfsfile),
      ),
    );
  }
}
