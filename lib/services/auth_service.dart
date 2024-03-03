
import 'package:get/get.dart';

class AuthService extends GetxService{
  final RxBool isLogin = false.obs;
  Future<AuthService> init() async => this;
  void setLogin(bool newValue){
    isLogin.value = newValue;
  }
}