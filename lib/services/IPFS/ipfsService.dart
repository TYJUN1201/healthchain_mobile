import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:healthchain/constants/ipfs/ipfs_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import '../../constants/blockchain/eth_constants.dart';
import '../../models/ipfs_file.dart';

class IPFSService {
  static Future<String> pinFileToIPFS(Map<String, dynamic> dataInJSON) async {
    final url = Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS');
    try {
      // Send the POST api request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${IPFSConstants.jwt}',
          'pinata_api_key': IPFSConstants.pinataApiKey,
          'pinata_secret_api_key': IPFSConstants.pinataSecretApiKey,
        },
        body: jsonEncode(dataInJSON),
      );

      // Handle the response here
      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        return json.decode(response.body)['IpfsHash'];
      } else {
        print('Error: ${response.reasonPhrase}');
        return '';
      }
    } catch (error) {
      // Handle the error here
      print('Error: $error');
    }
    return '';
  }

  static Future<String> uploadToBlockChain(String ipfsCID) async {
    final client = Web3Client(EthConstants.blockchainUrl, http.Client());

    // Get public address from user's private key
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey') ?? '0';
    final credentials = EthPrivateKey.fromHex(privateKey);
    final senderAddress = credentials.address;

    try {
      // Get contract function
      DeployedContract contract = DeployedContract(
          ContractAbi.fromJson(
              jsonEncode(jsonDecode(await rootBundle
                  .loadString("assets/json/Storage.json"))["abi"]),
              'Storage'),
          EthereumAddress.fromHex(EthConstants.ContractAddress));
      final ContractFunction contractFunction = contract.function('store');

      // Create transaction
      final Transaction tx = Transaction.callContract(
        contract: contract,
        function: contractFunction,
        parameters: [ipfsCID],
        from: senderAddress,
        value: EtherAmount.fromInt(
          EtherUnit.gwei,
          0,
        ),
      );

      // Send transaction
      final receipt = await client.sendTransaction(
        credentials,
        tx,
        chainId: EthConstants.ChainId,
      );

      return receipt;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<IPFSFile> getIPFSFile(String ipfsCID) async {
    try {
      final response =
          await http.get(Uri.parse('${IPFSConstants.ipfsGatewayUrl}$ipfsCID'));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseFile = jsonDecode(response.body);
        responseFile['encryptedFile'] =
            jsonDecode(responseFile['encryptedFile']);
        return IPFSFile.fromJson(ipfsCID, responseFile);
      } else {
        print(
            'Failed to fetch file for this CID: $ipfsCID. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed at getIPFSFile: $e');
    }
    return IPFSFile(ipfsCID: ipfsCID);
  }
}
