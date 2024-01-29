import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:desnet/models/eth/ethereum_transaction.dart';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';

enum EIP155Methods {
  ethSendTransaction,
}

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

class EIP155 {
  static final Map<EIP155Methods, String> methods = {
    EIP155Methods.ethSendTransaction: 'eth_sendTransaction',
  };

  static Future<dynamic> callMethod({
    required Web3App web3App,
    required String topic,
    required EIP155Methods method,
    required String chainId,
    required String toAddress, // '0xDB5332457aed22aB904212c2B8b40C18e6937440';
    required String fromAddress,// '0xd2415d678954c68e5132B3b73C7f327EA7adbb20';
    required List<dynamic> parameters, // ['QmX5TodM66Djvp7a9TPxUeUBzt2DfPU8hb2Q3UrYw6VeZY'];
    required Transaction transaction,
  }) async {
    switch (method) {
      case EIP155Methods.ethSendTransaction:
        return ethSendTransaction(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          transaction:
          EthereumTransaction(
            from: fromAddress,
            to: toAddress,
            value: '0x${transaction.value?.getInWei.toRadixString(16) ?? '0'}',
            data: transaction.data != null ? bytesToHex(transaction.data!) : null,
          ),
        );
    }
  }

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
