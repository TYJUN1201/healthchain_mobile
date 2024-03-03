import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:healthchain/helpers/auth_helper.dart';
import 'package:healthchain/helpers/validator_helper.dart';
import 'package:healthchain/pages/authentication/forget_password.dart';
import 'package:healthchain/pages/authentication/sign_up.dart';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'dart:async';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthchain/firebase_options.dart';
import 'package:healthchain/providers/auth_provider.dart' as AuthProv;
import 'package:provider/provider.dart' as Prov;
import '../../routes.dart';
import '../../widgets/chat/loading_view.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final emailField = TextEditingController();
  final passwordField = TextEditingController();
  bool logoutVisible = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailField.dispose();
    passwordField.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final themeMap = HashMap<String, String>();
    themeMap['primary'] = "#F5820D";

    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse(dotenv.env['ANDROID_REDIRECT_URL']!);
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse(dotenv.env['IOS_REDIRECT_URL']!);
    } else {
      throw UnKnownException('Unknown platform');
    }

    final loginConfig = HashMap<String, LoginConfigItem>();
    loginConfig['jwt'] = LoginConfigItem(
      verifier: "w3a-healthchain-verifier",
      typeOfLogin: TypeOfLogin.jwt,
      clientId: dotenv.env['CLIENT_ID']!, // auth0 client id
    );

    await Web3AuthFlutter.init(
      Web3AuthOptions(
        clientId: dotenv.env['CLIENT_ID']!,
        network: Network.sapphire_devnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(
          appName: dotenv.env['APP_NAME']!,
          logoLight: dotenv.env['LOGO_LIGHT']!,
          logoDark: dotenv.env['LOGO_DARK']!,
          defaultLanguage: Language.en,
          mode: ThemeModes.auto,
          appUrl: dotenv.env['APP_URL']!,
          useLogoLoader: true,
          theme: themeMap,
        ),
        loginConfig: loginConfig,
        // 259200 allows user to stay authenticated for 3 days with Web3Auth.
        // Default is 86400, which is 1 day.
        sessionTime: 259200,
      ),
    );

    await Web3AuthFlutter.initialize();

    final String res = await Web3AuthFlutter.getPrivKey();
    log(res);
    if (res.isNotEmpty) {
      setState(() {
        logoutVisible = true;
      });
    }
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
      key: const Key("loginScreen"),
        appBar: AppBar(
          title: const Text("HealthChain"),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 30),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Please sign in to continue.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              key: const Key("email"),
                              validator: (value) =>
                                  ValidatorHelper().validEmailAddressFormat(value!),
                              controller: emailField,
                              decoration: const InputDecoration(
                                // contentPadding: EdgeInsets.all(20),
                                  border: UnderlineInputBorder(),
                                  labelText: "Email Address"),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              key: const Key("password"),
                              validator: (value) =>
                                  ValidatorHelper().validPasswordFormat(value!),
                              controller: passwordField,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                // contentPadding: EdgeInsets.all(20),
                                border: UnderlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    key: const Key("login"),
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
                                      child: const Text(
                                          "Login",
                                          style: TextStyle(fontSize: 16, color: Colors.white)
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          authProvider
                                              .handleEmailSignIn(
                                              emailField.text, passwordField.text)
                                              .then((isSuccess) {
                                            if (isSuccess) {
                                              AuthHelper.loginWeb3Auth(() =>
                                                  AuthHelper.withEmailJWT(
                                                      emailField.text,
                                                      passwordField.text))
                                                  .then((loginResult) {
                                                Get.offAndToNamed(Routes.home);
                                              }).catchError((error, stackTrace) {
                                                Fluttertoast.showToast(
                                                    msg: error.toString());
                                                authProvider.handleException();
                                              });
                                            }
                                          });
                                        }
                                      }),
                                  ElevatedButton(
                                    onPressed: () async {
                                      authProvider.handleGoogleSignIn().then((idToken) {
                                        if (idToken != null) {
                                          AuthHelper.loginWeb3Auth(
                                                  () => AuthHelper.withGoogleJWT(idToken))
                                              .then((loginResult) {
                                            print('Google Login result: $loginResult');
                                            Get.offAndToNamed(Routes.home);
                                          }).catchError((error, stackTrace) {
                                            Fluttertoast.showToast(msg: error.toString());
                                            authProvider.handleException();
                                          });
                                        }
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                          if (states.contains(MaterialState.pressed)) {
                                            return const Color(0xffffffff).withOpacity(0.8);
                                          }
                                          return const Color(0xffffffff);
                                        },
                                      ),
                                      splashFactory: NoSplash.splashFactory,
                                      padding: MaterialStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.fromLTRB(30, 15, 30, 15),
                                      ),
                                    ),
                                    child: const Image(
                                      image: AssetImage("assets/google_logo.png"),
                                      height: 20.0,
                                      width: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                    Flexible(child: Container()),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Dont have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()),
                                );
                              },
                              child: const Text("Sign Up"),
                            )
                          ],
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ForgotPassword()),
                              );
                            },
                            child: const Text("Forgot Password?"),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              child: authProvider.status ==
                                  AuthProv.Status.authenticating
                                  ? const LoadingView()
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        )
                      ],
                    )
                  ]
              ),
            )
        )
    );
  }
}
