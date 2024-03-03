import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:healthchain/constants/constants.dart';
import 'package:healthchain/helpers/auth_helper.dart';
import 'package:healthchain/helpers/validator_helper.dart';
import 'package:healthchain/pages/authentication/sign_in.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart';
import 'package:healthchain/providers/auth_provider.dart' as AuthProv;
import 'package:provider/provider.dart' as Prov;

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  final emailField = TextEditingController();
  final roleField = TextEditingController();
  final passwordField = TextEditingController();
  final nameField = TextEditingController();
  final confirmPasswordField = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Uint8List? fileBytes;
  String filename = "";
  String imagePath = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailField.dispose();
    roleField.dispose();
    passwordField.dispose();
    nameField.dispose();
    confirmPasswordField.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthProv.AuthProvider authProvider =
        Prov.Provider.of<AuthProv.AuthProvider>(context);
    switch (authProvider.status) {
      case AuthProv.Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case AuthProv.Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case AuthProv.Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("HealthChain"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 116,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Please register an account",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Center(
                              child: CupertinoButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                          withData: true, type: FileType.image);
                                  if (result != null) {
                                    Uint8List? data = result.files.first.bytes;
                                    String name = result.files.first.name;
                                    imagePath = result.files.first.path!;
                                    setState(() {
                                      fileBytes = data;
                                      filename = name;
                                    });
                                  }
                                },
                                child: filename.isEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(45),
                                        child: const Icon(
                                          Icons.account_circle,
                                          size: 90,
                                          color: ColorConstants.greyColor,
                                        ))
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(45),
                                        child: Image.memory(
                                          fileBytes!,
                                          fit: BoxFit.cover,
                                          width: 90,
                                          height: 90,
                                          errorBuilder:
                                              (context, object, stackTrace) {
                                            return const Icon(
                                              Icons.account_circle,
                                              size: 90,
                                              color: ColorConstants.greyColor,
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ),
                            TextFormField(
                              controller: nameField,
                              decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: "Name"),
                            ),
                            DropdownButtonFormField<String>(
                              value: roleField.text.isEmpty
                                  ? "Patient"
                                  : roleField.text,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "Role",
                              ),
                              items: ["Patient", "Doctor", "Pharmacist"]
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  roleField.text = value ?? "";
                                });
                              },
                            ),
                            TextFormField(
                              validator: (value) => ValidatorHelper()
                                  .validEmailAddressFormat(value.toString()),
                              controller: emailField,
                              decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: "Email Address"),
                            ),
                            TextFormField(
                              validator: (value) => ValidatorHelper()
                                  .validPasswordFormat(value.toString()),
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: passwordField,
                              decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: "Password"),
                            ),
                            TextFormField(
                              validator: (value) => ValidatorHelper()
                                  .validConfirmPasswordFormat(
                                      value.toString(), passwordField.text),
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: confirmPasswordField,
                              decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: "Confirm Password"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.pressed)) {
                                              return const Color(0xffdd4b39)
                                                  .withOpacity(0.8);
                                            }
                                            return const Color(0xffdd4b39);
                                          },
                                        ),
                                        fixedSize: MaterialStateProperty.all(
                                            const Size(230, 50))),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        Map<String, dynamic> response =
                                            await AuthHelper.registerUser(
                                                emailField.text,
                                                passwordField.text,
                                                nameField.text,
                                                roleField.text,
                                                context);
                                        if (response["status"] == 200) {
                                          final uploadTask =
                                              await FirebaseStorage.instance
                                                  .ref('uploads/$filename')
                                                  .putData(fileBytes!);
                                          final filepath = await FirebaseStorage
                                              .instance
                                              .ref('uploads/$filename')
                                              .getDownloadURL();
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          String id = prefs
                                              .get(FirestoreConstants.id)
                                              .toString();
                                          FirebaseFirestore.instance
                                              .collection(FirestoreConstants
                                                  .pathUserCollection)
                                              .doc(id)
                                              .update({
                                            "photoUrl": filepath,
                                          });
                                          authProvider
                                              .handleEmailSignIn(
                                                  emailField.text,
                                                  passwordField.text)
                                              .then((isSuccess) {
                                            if (isSuccess) {
                                              AuthHelper.loginWeb3Auth(() =>
                                                      AuthHelper.withEmailJWT(
                                                          emailField.text,
                                                          passwordField.text))
                                                  .then((loginResult) {
                                                Get.offAndToNamed(Routes.home);
                                              }).catchError(
                                                      (error, stackTrace) {
                                                Fluttertoast.showToast(
                                                    msg: error.toString());
                                              });
                                            }
                                          });
                                        }
                                        Fluttertoast.showToast(
                                            msg: response["message"]);
                                      }
                                    },
                                    child: const Text("Sign Up",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white))),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
              Flexible(child: Container()),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          },
                          child: const Text("Sign In"),
                        )
                      ])),
            ],
          ),
        ),
      ),
    );
  }
}
