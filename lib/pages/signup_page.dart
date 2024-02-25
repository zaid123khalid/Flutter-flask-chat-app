import 'dart:convert';

import 'package:chat_app/Widgets/app_button.dart';
import 'package:chat_app/Widgets/text_field.dart';
import 'package:chat_app/controllers/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final SignupController _signupController = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Form(
            key: _signupController.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Signup',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                AppTextField(
                  controller: _signupController.usernameController,
                  hintText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  validator: (p0) {
                    if (p0!.isEmpty) {
                      return "Name cannot be empty";
                    } else if (p0.length < 3) {
                      return "Name must be atleast 3 characters long";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                AppTextField(
                  controller: _signupController.emailController,
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  validator: (p0) {
                    if (p0!.isEmpty) {
                      return "Email cannot be empty";
                    } else if (!p0.contains("@")) {
                      return "Email is not valid";
                    } else if (!p0.contains(".")) {
                      return "Email is not valid";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(
                  () => AppTextField(
                    isAutoValidateMode: true,
                    controller: _signupController.passwordController,
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: _signupController.isPasswordVisible.value,
                    suffixIcon: IconButton(
                      onPressed: () {
                        _signupController.togglePasswordVisibility();
                      },
                      icon: Icon(
                        _signupController.isPasswordVisible.value == true
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
                Obx(
                  () => AppTextField(
                    isAutoValidateMode: true,
                    controller: _signupController.confirmPasswordController,
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    obscureText:
                        _signupController.isConfirmPasswordVisible.value,
                    suffixIcon: IconButton(
                      onPressed: () {
                        _signupController.toggleConfirmPasswordVisibility();
                      },
                      icon: Icon(
                        _signupController.isConfirmPasswordVisible.value == true
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return "Confirm Password cannot be empty";
                      } else if (p0 !=
                          _signupController.passwordController.text) {
                        return "Confirm Password does not match";
                      }
                      return null;
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
                    onPressed: () async {
                      if (_signupController.formKey.currentState!.validate()) {
                        if (_signupController.passwordController.text ==
                            _signupController.confirmPasswordController.text) {
                          final resp = await _signupController.signup();
                          if (json.decode(resp.body)['status'] == 'success') {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 1000),
                                content: Text(
                                  json.decode(resp.body)['message'],
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content: Text(
                                  "Password and Confirm Password does not match"),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
