import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:healthchain/routes.dart';
import 'package:healthchain/services/auth_service.dart';

class AuthGuard extends GetMiddleware{
 final authService = Get.find<AuthService>();

 @override
 RouteSettings? redirect(String? route) {
  // Navigate to login if client is not authenticated other wise continue
  if (FirebaseAuth.instance.currentUser != null) return null;
  return const RouteSettings(name: Routes.signIn);
 }
}