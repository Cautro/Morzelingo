import 'package:flutter/material.dart';
import 'package:morzelingo/storage_context.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    String? theme = await StorageService.getItem("theme");

    if (theme == "light") {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await StorageService.setItem("theme", "light");
    } else {
      _themeMode = ThemeMode.dark;
      await StorageService.setItem("theme", "dark");
    }

    notifyListeners();
  }

}
final ThemeController themeController = ThemeController();
