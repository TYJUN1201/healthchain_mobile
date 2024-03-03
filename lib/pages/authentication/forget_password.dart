import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:healthchain/helpers/auth_helper.dart';

import '../../routes.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailInput = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("HealthChain"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 30),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 150,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: emailInput,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Email"
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child:
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed)) {
                                      return const Color(0xffdd4b39).withOpacity(0.8);
                                    }
                                    return const Color(0xffdd4b39);
                                  },
                                ),
                                fixedSize: MaterialStateProperty.all(const Size(230, 50))
                            ),
                            onPressed: () async {
                              var response = await AuthHelper().resetPassword(emailInput.text);
                              if(response["status"] == 200){
                                Get.offAndToNamed(Routes.signIn);
                              }
                              Fluttertoast.showToast(msg: response["message"]);
                            },
                            child: const Text(
                                "Submit",
                                style: TextStyle(fontSize: 16, color: Colors.white)
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
