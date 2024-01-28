import 'dart:convert';
import 'package:desnet/pages/profile_page.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class StorageContract {
  late DeployedContract contract;
  late EthereumAddress contractAddress;
  late Web3Client ethClient;
  late String abiFile;

  StorageContract(String contractAddress, String blockchainUrl) {
    _initialize(contractAddress, blockchainUrl);
  }

  Future<void> _initialize(String contractAddress, String blockchainUrl) async {
    await getContract(contractAddress, blockchainUrl);
  }

  Future<void> getContract(String contractAddress, String blockchainUrl) async {
    try {
      this.contractAddress = EthereumAddress.fromHex(contractAddress);
      this.ethClient = Web3Client(blockchainUrl, http.Client());
      this.abiFile = await rootBundle.loadString("assets/json/Storage.json");
      this.contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(jsonDecode(abiFile)["abi"]), 'Storage'),
        this.contractAddress,
      );
    } catch (e) {
      print('Error initializing contract: $e');
    }
  }
  
  Future<List<UserFile>> callContractFunction(String _metamaskAddress, String functionName) async {
    try {
      final EthereumAddress sender = EthereumAddress.fromHex(_metamaskAddress);
      final result = await ethClient.call(
        sender: sender,
        contract: contract,
        function: contract.function(functionName),
        params: [],
      );

      List<UserFile> allFiles = [];
      for (var fileDataList in result[0]) {
        if (fileDataList is List<dynamic> && fileDataList.isNotEmpty) {
          String ipfsHash = fileDataList[0].toString();
          allFiles.add(UserFile(ipfsHash: ipfsHash));
        }
      }

      return allFiles;
    } catch (e) {
      // Handle the exception here
      print('Error occurred: $e');
      return [];
    }
  }
}