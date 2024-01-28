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
  String blockchainUrl = '';

  StorageContract(EthereumAddress contractaddress, String blockchainurl) {
    contractAddress = contractaddress;
    blockchainUrl = blockchainurl;
    _initialize(contractAddress, blockchainUrl);
  }

  Future<void> _initialize(EthereumAddress contractAddress, String blockchainUrl) async {
    await getContract(contractAddress, blockchainUrl);
  }

  Future<void> getContract(EthereumAddress contractAddress, String blockchainUrl) async {
    try {
      ethClient = Web3Client(blockchainUrl, http.Client());
      abiFile = await rootBundle.loadString("assets/json/Storage.json");
      contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(jsonDecode(abiFile)["abi"]), 'Storage'),
        this.contractAddress,
      );
    } catch (e) {
      print('Error initializing contract: $e');
    }
  }

  Future<dynamic> callContractFunction(String address, String functionName, List<dynamic> params) async {
    try {
      await _initialize(contractAddress, blockchainUrl);
      final EthereumAddress sender = EthereumAddress.fromHex(address);
      final result = await ethClient.call(
        sender: sender,
        contract: contract,
        function: contract.function(functionName),
        params: params,
      );

      return result;
    } catch (e) {
      // Handle the exception here
      print('Error occurred: $e');
      return null;
    }
  }
}
