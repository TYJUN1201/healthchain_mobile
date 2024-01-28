import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<void> pinFileToIPFS(
    String pinataApiKey, String pinataSecretApiKey, String encryptedFile, String encryptedAESKey) async {
  final url = Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS');

  final jsonString = '{"encrytedFile": "$encryptedFile", "encryptedAESKey": "$encryptedAESKey"}';

  const jwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiI3MDRjMjViZC00MTYyLTQxMzMtOTE3OS1kMjVlMGNkZjNiZWIiLCJlbWFpbCI6InRhbnlvbmdqdW44OUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGluX3BvbGljeSI6eyJyZWdpb25zIjpbeyJpZCI6IkZSQTEiLCJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MX0seyJpZCI6Ik5ZQzEiLCJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MX1dLCJ2ZXJzaW9uIjoxfSwibWZhX2VuYWJsZWQiOmZhbHNlLCJzdGF0dXMiOiJBQ1RJVkUifSwiYXV0aGVudGljYXRpb25UeXBlIjoic2NvcGVkS2V5Iiwic2NvcGVkS2V5S2V5IjoiZmYzZjUzMDBiMmNkNmFhYzBlODEiLCJzY29wZWRLZXlTZWNyZXQiOiI1ZmMyZjA3ZTE3YzgyMmNiN2IyODdiNTdmNDFlOWYzMmE3ZjViYzc0NmE3OGYwMDY0NjgyNzkxYzQ3NTExNjVlIiwiaWF0IjoxNzA2MjA1NDExfQ.NQq1X4p6S6AdSUyX71UxgsQu3HCQ2S5TwtA3tAyLM50';
  try {
    // Send the request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
        'pinata_api_key': pinataApiKey,
        'pinata_secret_api_key': pinataSecretApiKey,
      },
      body: jsonString,
    );

    // Handle the response here
    if (response.statusCode == 200) {
      print('Success: ${response.body}');
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  } catch (error) {
    // Handle the error here
    print('Error: $error');
  }
}

Future<String> fetchFileToPinataIPFS(String data) async {
  // IPFS API endpoint
  String ipfsEndpoint = "https://gateway.pinata.cloud/ipfs/";

  // Create a FormData with the encrypted message as a file
  var formData = http.MultipartRequest('POST', Uri.parse(ipfsEndpoint));
  formData.files.add(http.MultipartFile.fromString('file', data));

  // Send the request to IPFS
  var response = await formData.send();
  var responseData = await response.stream.bytesToString();

  // Parse the IPFS response to get the hash
  var ipfsResponse = json.decode(responseData);
  var ipfsHash = ipfsResponse['Hash'];

  return ipfsHash;
}
