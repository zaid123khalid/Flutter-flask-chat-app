import 'package:chat_app/pages/splash_page.dart';
import 'package:chat_app/providers/theme_provider.dart';
import 'package:chat_app/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  getThemeFromHive() async {
    var box = await Hive.openBox('user');
    if (box.get('theme') != null) {
      return box.get('theme');
    } else {
      return false;
    }
  }

  setTheme(context) async {
    Provider.of<ThemeProvider>(context, listen: false).isDark =
        await getThemeFromHive() as bool;
  }

  @override
  Widget build(BuildContext context) {
    setTheme(context);
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Theme.of(context).colorScheme.primary,
          iconColor: Colors.white,
          labelTextStyle: const MaterialStatePropertyAll<TextStyle>(
            TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.8,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            textStyle: const MaterialStatePropertyAll<TextStyle>(
              TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          trackColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          trackOutlineColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: Theme.of(context).colorScheme.onBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Theme.of(context).colorScheme.primary,
          iconColor: Colors.white,
          labelTextStyle: const MaterialStatePropertyAll<TextStyle>(
            TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.8,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            textStyle: const MaterialStatePropertyAll<TextStyle>(
              TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          trackColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          trackOutlineColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
      ),
      themeMode: Provider.of<ThemeProvider>(context, listen: true).isDark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const SplashPage(),
    );
  }
}
