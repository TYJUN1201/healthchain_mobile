class IPFSFile {
  final String ipfsCID;
  final String? fileType;
  final String? fileName;
  final Map<dynamic, dynamic>? encryptedFile;
  Map<dynamic, dynamic>? encryptedAesSecretKey;

  IPFSFile({
    required this.ipfsCID,
    this.fileType,
    this.fileName,
    this.encryptedFile,
    this.encryptedAesSecretKey,
  });

  factory IPFSFile.fromJson(String ipfsCID, Map<String, dynamic> fileJson) {
    return IPFSFile(
      ipfsCID: ipfsCID,
      fileType: fileJson['fileType'],
      fileName: fileJson['fileName'],
      encryptedFile: fileJson['encryptedFile'],
      encryptedAesSecretKey: fileJson['encryptedAesSecretKey'],
    );
  }
}

// {
//    "fileType",
//    "fileName",
//    "encryptedFile":"{
//        "Ciphertext",
//        "Nonce",
//        "MAC"
//    },
//    "encryptedAesSecretKey":{
// 	      "version",
// 	      "nonce",
// 	      "ephemPublicKey",
// 	      "ciphertext"
//    }
// }