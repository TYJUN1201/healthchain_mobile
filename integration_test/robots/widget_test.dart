import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:healthchain/firebase_options.dart';
import 'package:healthchain/services/auth_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:healthchain/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

class LoginRobot{
  final WidgetTester tester;
  LoginRobot(this.tester);

  Future<void> enterEmail(String email) async {
    final usernameField = find.byKey(const Key("email"));
    expect(usernameField, findsOneWidget);
    await tester.enterText(usernameField, email);
    await tester.pump();
  }
  Future<void> enterPassword(String password) async {
    final passwordField = find.byKey(const Key("password"));
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, password);
    await tester.pump();
  }
  Future<void> login() async {
    final loginButton = find.byKey(const Key("login"));
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }
  void verify(){
    final loginScreen = find.byKey(const Key("loginScreen"));
    expect(loginScreen, findsOneWidget);
  }
}

Future<void> main() async {
  await dotenv.load(fileName: "lib/.env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.putAsync(() => AuthService().init());
  SharedPreferences prefs = await SharedPreferences.getInstance();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late LoginRobot loginRobot;

  testWidgets("login flow", (widgetTester) async {
    await widgetTester.pumpWidget(app.MyApp(prefs: prefs,));
    loginRobot = LoginRobot(widgetTester);
    loginRobot.verify();

    await loginRobot.enterEmail("tommytesting9@gmail.com");
    await loginRobot.enterPassword("123456");
    await loginRobot.login();
  });
}