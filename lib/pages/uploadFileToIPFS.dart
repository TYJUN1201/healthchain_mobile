import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/utils/namespace_utils.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/web3app.dart';
import '../services/IPFS/upload_file.dart';
import '../utils/constants.dart';
import '../utils/crypto/eip155.dart';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({
    super.key,
    required this.web3App,
  });

  final Web3App web3App;

  @override
  _UploadFilePageState createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  TextEditingController senderAddressController = TextEditingController();
  Map<String, SessionData> _activeSessions = {};
  SessionData? _sessionData;
  String userMetamaskAddress = '';
  final String contractAddress = '0xDB5332457aed22aB904212c2B8b40C18e6937440';
  final String emr = "{'name':'digimon'}";
  final String pinataApiKey = 'ff3f5300b2cd6aac0e81';
  final String pinataSecretApiKey =
      '5fc2f07e17c822cb7b287b57f41e9f32a7f5bc746a78f0064682791c4751165e';

  @override
  void initState() {
    _activeSessions = widget.web3App.getActiveSessions();
    _sessionData = _activeSessions[_activeSessions.keys.toList().first];
    userMetamaskAddress = NamespaceUtils.getAccount(
        _sessionData!.namespaces.values.first.accounts.first);

    super.initState();
  }

  Future<void> uploadCIDtoChain(String senderAddress, String fileCID) async {
    try {
      DeployedContract contract = DeployedContract(
          ContractAbi.fromJson(
              jsonEncode(jsonDecode(await rootBundle
                  .loadString("assets/json/Storage.json"))["abi"]),
              'Storage'),
          EthereumAddress.fromHex(contractAddress));

      final ContractFunction contractFunction = contract.function('store');

      final Transaction tx = Transaction.callContract(
        contract: contract,
        function: contractFunction,
        parameters: [fileCID],
      );

      EIP155.callMethod(
          web3App: widget.web3App,
          topic: _sessionData!.topic,
          method: EIP155Methods.ethSendTransaction,
          chainId: 'eip155:1337',
          toAddress: contractAddress,
          fromAddress: senderAddress,
          parameters: [fileCID],
          transaction: tx);
    } catch (e) {
      print("Error loading files: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload File to IPFS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emr,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final walletUrl = _sessionData?.peer.metadata.redirect?.native;
                if ((walletUrl ?? '').isNotEmpty) {
                  launchUrlString(
                    walletUrl!,
                    mode: LaunchMode.externalApplication,
                  );
                }

                final fileCID = await pinFileToIPFS(
                    pinataApiKey, pinataSecretApiKey, emr, 'ABCDEFG');
                print(fileCID);
                await uploadCIDtoChain(userMetamaskAddress, fileCID);
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
                'Upload File',
                style: StyleConstants.buttonText,
                textAlign: TextAlign.center,
              ),
              // Implement the logic to upload the file to IPFS using senderAddress
            ),
          ],
        ),
      ),
    );
  }
}
