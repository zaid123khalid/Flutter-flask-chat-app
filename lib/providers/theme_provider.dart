import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;
  bool get isLight => !_isDark;

  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    saveTheme();
    notifyListeners();
  }

  saveTheme() async {
    var box = await Hive.openBox('user');
    box.put('theme', _isDark);
  }
}
