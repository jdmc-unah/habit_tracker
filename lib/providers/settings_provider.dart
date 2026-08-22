import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;

  bool get isDarkTheme => _isDarkTheme;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('app_dark_theme') ?? false;
    _notificationsEnabled = prefs.getBool('app_notifications_enabled') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_dark_theme', _isDarkTheme);
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_notifications_enabled', _notificationsEnabled);
  }
}
