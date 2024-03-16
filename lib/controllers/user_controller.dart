import 'package:get/get.dart';

class UserController extends GetxController {
  RxString username = ''.obs;
  RxString email = ''.obs;
  RxString password = ''.obs;

  setUsername(String value) {
    username.value = value;
  }

  setEmail(String value) {
    email.value = value;
  }

  setPassword(String value) {
    password.value = value;
  }
}
