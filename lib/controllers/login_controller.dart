import 'dart:convert';

import 'package:chat_app/Services/http_conn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LoginController extends GetxController {
  HttpConnection http = HttpConnection();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  RxBool rememberMe = false.obs;
  RxBool isPasswordVisible = true.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = !rememberMe.value;
  }

  login() async {
    var response = await http.post(url: '/login', body: {
      "username": usernameController.text,
      "password": passwordController.text,
      "rememberMe": rememberMe.value,
    }, headers: {
      "Content-Type": "application/json",
    });
    if (response.statusCode == 200) {
      setToken(json.decode(response.body)['token']);
      storeUserDetails();
    }
    return response;
  }

  setToken(String token) async {
    var hiveBox = await Hive.openBox('user');
    hiveBox.put('token', token);
  }

  storeUserDetails() async {
    var hiveBox = await Hive.openBox('user');
    hiveBox.put('username', usernameController.text);
    hiveBox.put('password', passwordController.text);
    hiveBox.put('rememberMe', rememberMe.value);
  }
}
