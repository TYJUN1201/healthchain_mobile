import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:desnet/models/eth/ethereum_transaction.dart';
import 'package:desnet/utils/test_data.dart';
import 'package:desnet/services/smartcontract/storageContract.dart';

import 'dart:convert';
import 'package:desnet/pages/profile_page.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

enum EIP155Methods {
  // personalSign,
  // ethSign,
  // ethSignTransaction,
  // ethSignTypedData,
  ethSendTransaction,
}

// enum EIP155Events {
//   chainChanged,
//   accountsChanged,
// }

extension EIP155MethodsX on EIP155Methods {
  String? get value => EIP155.methods[this];
}

extension EIP155MethodsStringX on String {
  EIP155Methods? toEip155Method() {
    final entries = EIP155.methods.entries.where(
      (element) => element.value == this,
    );
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}

// extension EIP155EventsX on EIP155Events {
//   String? get value => EIP155.events[this];
// }

// extension EIP155EventsStringX on String {
//   EIP155Events? toEip155Event() {
//     final entries = EIP155.events.entries.where(
//       (element) => element.value == this,
//     );
//     return (entries.isNotEmpty) ? entries.first.key : null;
//   }
// }

class EIP155 {
  static final Map<EIP155Methods, String> methods = {
    // EIP155Methods.personalSign: 'personal_sign',
    // EIP155Methods.ethSign: 'eth_sign',
    // EIP155Methods.ethSignTransaction: 'eth_signTransaction',
    // EIP155Methods.ethSignTypedData: 'eth_signTypedData',
    EIP155Methods.ethSendTransaction: 'eth_sendTransaction',
  };

  // static final Map<EIP155Events, String> events = {
  //   EIP155Events.chainChanged: 'chainChanged',
  //   EIP155Events.accountsChanged: 'accountsChanged',
  // };

  static Future<dynamic> callMethod({
    required Web3App web3App,
    required String topic,
    required EIP155Methods method,
    required String chainId,
    required String address,
  }) async {
    switch (method) {
      // case EIP155Methods.personalSign:
      //   return personalSign(
      //     web3App: web3App,
      //     topic: topic,
      //     chainId: chainId,
      //     address: address,
      //     data: testSignData,
      //   );
      // case EIP155Methods.ethSign:
      //   return ethSign(
      //     web3App: web3App,
      //     topic: topic,
      //     chainId: chainId,
      //     address: address,
      //     data: testSignData,
      //   );
      // case EIP155Methods.ethSignTypedData:
      //   return ethSignTypedData(
      //     web3App: web3App,
      //     topic: topic,
      //     chainId: chainId,
      //     address: address,
      //     data: typedData,
      //   );
      // case EIP155Methods.ethSignTransaction:
      //   return ethSignTransaction(
      //     web3App: web3App,
      //     topic: topic,
      //     chainId: chainId,
      //     transaction: EthereumTransaction(
      //       from: address,
      //       to: address,
      //       value: '0x01',
      //     ),
      //   );
      case EIP155Methods.ethSendTransaction:
        final contractAddress = '0xDB5332457aed22aB904212c2B8b40C18e6937440';
        final userAddress = '0xd2415d678954c68e5132B3b73C7f327EA7adbb20';
        final fileCID = 'QmX5TodM66Djvp7a9TPxUeUBzt2DfPU8hb2Q3UrYw6VeZY';

        DeployedContract contract = DeployedContract(
            ContractAbi.fromJson(
                jsonEncode(jsonDecode(await rootBundle
                    .loadString("assets/json/Storage.json"))["abi"]),
                'Storage'),
            EthereumAddress.fromHex(
                contractAddress));

        final ContractFunction contractFunction = contract.function('store');

        final Transaction tx = Transaction.callContract(
          contract: contract,
          function: contractFunction,
          parameters: [
            fileCID
          ],
        );

        // Map<String, dynamic> tJson = {
        //   'from': userAddress ?? tx.from?.hex,
        //   'to': tx.to?.hex,
        //   'gas': tx.maxGas != null ? 'Ox${tx.maxGas!.toRadixString(16)}' : null,
        //   'gasPrice': '0x${tx.gasPrice?.getInWei.toRadixString(16) ?? '0'}',
        //   'value': '0x${tx.value?.getInWei.toRadixString(16) ?? '0'}',
        //   'data': tx.data != null ? bytesToHex(tx.data!) : null,
        //   'nonce': tx.nonce,
        // };

        return ethSendTransaction(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          transaction:
          EthereumTransaction(
            from: userAddress,
            to: contractAddress,
            value: '0x${tx.value?.getInWei.toRadixString(16) ?? '0'}',
            data: tx.data != null ? bytesToHex(tx.data!) : null,
          ),
        );
    }
  }

  // static Future<dynamic> personalSign({
  //   required Web3App web3App,
  //   required String topic,
  //   required String chainId,
  //   required String address,
  //   required String data,
  // }) async {
  //   return await web3App.request(
  //     topic: topic,
  //     chainId: chainId,
  //     request: SessionRequestParams(
  //       method: methods[EIP155Methods.personalSign]!,
  //       params: [data, address],
  //     ),
  //   );
  // }

  // static Future<dynamic> ethSign({
  //   required Web3App web3App,
  //   required String topic,
  //   required String chainId,
  //   required String address,
  //   required String data,
  // }) async {
  //   return await web3App.request(
  //     topic: topic,
  //     chainId: chainId,
  //     request: SessionRequestParams(
  //       method: methods[EIP155Methods.ethSign]!,
  //       params: [address, data],
  //     ),
  //   );
  // }
  //
  // static Future<dynamic> ethSignTypedData({
  //   required Web3App web3App,
  //   required String topic,
  //   required String chainId,
  //   required String address,
  //   required String data,
  // }) async {
  //   return await web3App.request(
  //     topic: topic,
  //     chainId: chainId,
  //     request: SessionRequestParams(
  //       method: methods[EIP155Methods.ethSignTypedData]!,
  //       params: [address, data],
  //     ),
  //   );
  // }
  //
  // static Future<dynamic> ethSignTransaction({
  //   required Web3App web3App,
  //   required String topic,
  //   required String chainId,
  //   required EthereumTransaction transaction,
  // }) async {
  //   return await web3App.request(
  //     topic: topic,
  //     chainId: chainId,
  //     request: SessionRequestParams(
  //       method: methods[EIP155Methods.ethSignTransaction]!,
  //       params: [transaction.toJson()],
  //     ),
  //   );
  // }

  static Future<dynamic> ethSendTransaction({
    required Web3App web3App,
    required String topic,
    required String chainId,
    required EthereumTransaction transaction,
  }) async {
    return await web3App.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155Methods.ethSendTransaction]!,
        params: [transaction.toJson()],
      ),
    );
  }
}
