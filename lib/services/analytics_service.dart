import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'auth_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Keep a local in-memory log of events for visual verification on web/desktop
  final List<Map<String, dynamic>> _localLog = [];
  List<Map<String, dynamic>> get localLog => List.unmodifiable(_localLog);

  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    final Map<String, dynamic> event = {
      'timestamp': DateTime.now().toIso8601String(),
      'name': name,
      'parameters': parameters,
    };

    _localLog.add(event);
    debugPrint('Analytics Event Logged: $name parameters=$parameters');

    if (AuthService.isFirebaseEnabled) {
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: name,
          parameters: parameters.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
      } catch (e) {
        debugPrint('Firebase Analytics logging failed: $e');
      }
    }
  }

  Future<void> logLogin(String method) async {
    await logEvent('login', {'method': method});
    if (AuthService.isFirebaseEnabled) {
      try {
        await FirebaseAnalytics.instance.logLogin(loginMethod: method);
      } catch (_) {}
    }
  }

  Future<void> logSignUp(String method) async {
    await logEvent('sign_up', {'method': method});
    if (AuthService.isFirebaseEnabled) {
      try {
        await FirebaseAnalytics.instance.logSignUp(signUpMethod: method);
      } catch (_) {}
    }
  }

  void clearLocalLog() {
    _localLog.clear();
  }
}
