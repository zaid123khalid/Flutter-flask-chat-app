import 'package:chat_app/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          foregroundColor: Colors.white,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          textStyle: TextStyle(color: Colors.white),
          labelTextStyle: MaterialStatePropertyAll(
            TextStyle(color: Colors.white),
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
