import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _key = 'isDarkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDarkMode);
    notifyListeners();
  }
}

// InheritedWidget สำหรับ pass ThemeService ลงไปใน widget tree
class ThemeServiceProvider extends InheritedWidget {
  final ThemeService themeService;

  const ThemeServiceProvider({
    super.key,
    required this.themeService,
    required super.child,
  });

  static ThemeService of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeServiceProvider>()!
        .themeService;
  }

  @override
  bool updateShouldNotify(ThemeServiceProvider oldWidget) => true;
}