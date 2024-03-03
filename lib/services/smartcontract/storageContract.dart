import 'dart:convert';
import 'package:healthchain/constants/blockchain/eth_constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class StorageContract {
  late DeployedContract contract;
  late Web3Client ethClient;
  late String abiFile;

  StorageContract() {
    _initializeContract();
  }

  Future<void> _initializeContract() async {
    await getContract();
  }

  Future<void> getContract() async {
    try {
      ethClient = Web3Client(EthConstants.blockchainUrl, http.Client());
      abiFile = await rootBundle.loadString("assets/json/Storage.json");
      contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(jsonDecode(abiFile)["abi"]), 'Storage'),
        EthereumAddress.fromHex(EthConstants.ContractAddress),
      );
    } catch (e) {
      print('Error initializing contract: $e');
    }
  }

  Future<dynamic> callContractFunction(EthereumAddress senderAddress, String functionName, List<dynamic> params) async {
    try {
      await _initializeContract();
      final result = await ethClient.call(
        sender: senderAddress,
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
