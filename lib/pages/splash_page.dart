import 'package:chat_app/controllers/home_controller.dart';
import 'package:chat_app/controllers/user_controller.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final HomeController _homeController = Get.put(HomeController());
  final UserController _userController = Get.put(UserController());
  getUserDetails() async {
    final box = await Hive.openBox('user');
    final username = box.get('username');
    final password = box.get('password');
    final rememberMe = box.get('rememberMe');
    return {
      "username": username,
      "password": password,
      "rememberMe": rememberMe,
    };
  }

  verifyToken() async {
    final token = await _homeController.getToken();
    final response = await _homeController.http.get(
      url: '/verify',
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails().then((value) async {
      if (value['rememberMe'] == null &&
          value['username'] == null &&
          value['password'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else if (value['rememberMe'] == true) {
        if (await verifyToken() && context.mounted) {
          print(value['username']);
          _userController.setUsername(value['username']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
