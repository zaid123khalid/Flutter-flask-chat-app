import 'dart:convert';
import 'package:chat_app/controllers/login_controller.dart';
import 'package:chat_app/Widgets/app_button.dart';
import 'package:chat_app/Widgets/text_field.dart';
import 'package:chat_app/controllers/user_controller.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _loginController = Get.put(LoginController());
  final UserController _userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Form(
              key: _loginController.formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AppTextField(
                      controller: _loginController.usernameController,
                      hintText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      validator: (p0) {
                        if (p0!.isEmpty) {
                          return "Username cannot be empty";
                        } else if (p0.length < 3) {
                          return "Username must be atleast 3 characters long";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Obx(
                      () => AppTextField(
                        obscureText: _loginController.isPasswordVisible.value,
                        controller: _loginController.passwordController,
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _loginController.togglePasswordVisibility();
                          },
                          icon: Icon(
                            _loginController.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        validator: (p0) {
                          if (p0!.isEmpty) {
                            return "Password cannot be empty";
                          } else if (p0.length < 8) {
                            return "Password must be atleast 8 characters long";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Obx(
                          () => Checkbox(
                              value: _loginController.rememberMe.value,
                              onChanged: (value) =>
                                  _loginController.toggleRememberMe(value)),
                        ),
                        const Text("Remember me"),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: AppButton(
                        text: "Login",
                        onPressed: () async {
                          if (_loginController.formKey.currentState!
                              .validate()) {
                            final resp = await _loginController.login();
                            if (json.decode(resp.body)['status'] == 'success') {
                              _userController.setUsername(
                                  _loginController.usernameController.text);
                              _loginController.usernameController.clear();
                              _loginController.passwordController.clear();
                              _loginController.rememberMe.value = false;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: AppButton(
                        text: "Sign Up",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
