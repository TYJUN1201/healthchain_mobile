import 'package:desnet/screen/metamask_encrypt_decrypt.dart';
import 'package:flutter/material.dart';
import 'package:desnet/screen/patientProfilePage.dart';
import 'package:desnet/services/IPFS/upload_file.dart';
import 'package:desnet/services/cryptography/aes_algorithm.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   final String pinataApiKey =
//       'ff3f5300b2cd6aac0e81'; // Replace with your actual API key
//   final String pinataSecretApiKey =
//       '5fc2f07e17c822cb7b287b57f41e9f32a7f5bc746a78f0064682791c4751165e'; //'5St1vYV4xfYX_dTs1K4VbuRspePITHSiz5jy7EK-Qu88aIFQ9zf2LTSbyinPDXKV';
//   // '5fc2f07e17c822cb7b287b57f41e9f32a7f5bc746a78f0064682791c4751165e'; // Replace with your actual secret API key
//
//   final String emr = "{'name':'pikachu'}";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pin File to IPFS'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 final AESEncryption aesEncryption = AESEncryption();
//                 final SecretBox secretBox;
//                 encrypted = await aesEncryption.encryptAES(emr);
//
//                 pinFileToIPFS(pinataApiKey, pinataSecretApiKey,
//                     utf8.decode(encrypted.cipherText), 'encrypted_AESKey');
//               },
//               child: Text('Pin File to IPFS'),
//             ),
//             SizedBox(
//               width: 300.0, // Set the desired width
//               height: 200.0,
//               child:
//                   PatientProfilePage(), // Assuming PatientProfilePage is a widget
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = "HealthChain";
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
      ),
      body: const Center(
        child: PatientProfilePage(),
      ),
    ), //MyHomePage(),
    );
  }
}
