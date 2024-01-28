import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:desnet/models/eth/ethereum_transaction.dart';
import 'package:desnet/utils/test_data.dart';
import 'package:desnet/services/smartcontract/storageContract.dart';

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
  }) {
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
        StorageContract storageContract = StorageContract(
          EthereumAddress.fromHex('0xDB5332457aed22aB904212c2B8b40C18e6937440'),
          "http://10.0.2.2:8545",
        );

        storageContract.ethClient.sendTransaction(Credentials, transaction)

        ContractFunction contractFunction = storageContract.contract.function('store');
        print(contractFunction.parameters);
        final storeData = storageContract.callContractFunction(
            '0x218164Ba1BdDBABB4867EbFd8e29e9c7642a5621', "Store", [
          '0x131a06800000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002e516d50674d6878677261416d636e454266516e7879714c44776d4b416178424d6d7464476a6e7261614d7062664e000000000000000000000000000000000000'
        ]);
        //print(contractFunction.encodeCall(['0x131a06800000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002e516d50674d6878677261416d636e454266516e7879714c44776d4b416178424d6d7464476a6e7261614d7062664e000000000000000000000000000000000000']).toString());
        return ethSendTransaction(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          transaction: EthereumTransaction(
            from: '0x218164Ba1BdDBABB4867EbFd8e29e9c7642a5621', //userAddress
            to: '0xDB5332457aed22aB904212c2B8b40C18e6937440', //contractAddress
            value: '0x001', //
            data: '',
                //'0x131a06800000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002e516d50674d6878677261416d636e454266516e7879714c44776d4b416178424d6d7464476a6e7261614d7062664e000000000000000000000000000000000000', //contract store function abi
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
