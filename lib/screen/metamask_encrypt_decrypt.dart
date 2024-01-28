// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:web3dart/web3dart.dart';
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final metamaskAddress = '0xYourMetaMaskAddress';
//   final ethereumNodeUrl = 'https://mainnet.infura.io/v3/YourInfuraApiKey';
//
//   late Web3Client client;
//
//   @override
//   void initState() {
//     super.initState();
//     client = Web3Client(ethereumNodeUrl, http.Client());
//   }
//
//   @override
//   void dispose() {
//     client.dispose();
//     super.dispose();
//   }
//
//   Future<void> getEncryptionPublicKey() async {
//     try {
//       final publicKey = await window.ethereum.request({
//         "method": "eth_getEncryptionPublicKey",
//         "params": [
//           null
//         ]
//       });
//       print('Encryption Public Key: $publicKey');
//     } catch (e) {
//       print('Error getting encryption public key: $e');
//     }
//   }
//
//   Future<void> decryptData() async {
//     // Replace with the encrypted data received from MetaMask
//     final encryptedData = 'yourEncryptedData';
//
//     try {
//       final decryptedData = await client.eth.decrypt(
//         encryptedData: encryptedData,
//         from: metamaskAddress,
//       );
//
//       print('Decrypted Data: $decryptedData');
//     } catch (e) {
//       print('Error decrypting data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('MetaMask Functions'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: getEncryptionPublicKey,
//               child: Text('Get Encryption Public Key'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: decryptData,
//               child: Text('Decrypt Data'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
