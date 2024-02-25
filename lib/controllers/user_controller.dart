import 'package:get/get.dart';

class UserController extends GetxController {
  RxString username = ''.obs;
  RxString email = ''.obs;
  RxString password = ''.obs;

  setUsername(String value) {
    print(value);

    username.value = value;

    print(username.value);
  }

  setEmail(String value) {
    email.value = value;
  }

  setPassword(String value) {
    password.value = value;
  }
}
