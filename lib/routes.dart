
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:healthchain/middlewares/auth_guard.dart';
import 'package:healthchain/pages/calendar/calendar_page.dart';
import 'package:healthchain/pages/authentication/sign_in.dart';
import 'package:healthchain/pages/authentication/sign_up.dart';
import 'package:healthchain/pages/chat/chat_page.dart';
import 'package:healthchain/pages/chat/chat_home_page.dart';
import 'package:healthchain/pages/dashboard/home.dart';
import 'package:healthchain/pages/mainPage.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

abstract class Routes {
  static const home = '/home';
  static const chat = '/chat';
  static const signIn = '/sign-in';
  static const signOut = '/sign-out';
  static const signUp = '/sign-up';
}


final appPages = [
  GetPage(
    name: Routes.home,
    page: () => MainPage(),
    middlewares: [
      AuthGuard()
    ]
  ),
  GetPage(
    name: Routes.chat,
    page: () => const ChatHomePage(), // ChatHomePage
  ),
  GetPage(
    name: Routes.signIn,
    page: () => const SignIn(),
  ),
  GetPage(
    name: Routes.signUp,
    page: () => SignUp(),
  ),
];
