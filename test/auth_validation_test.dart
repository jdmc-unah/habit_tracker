import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/providers/auth_provider.dart';

void main() {
  // Mock SharedPreferences
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Authentication Form Validation & State Tests', () {
    test('Login fails for invalid email format', () async {
      final authProvider = AuthProvider();

      // Trigger login with bad email format
      final result = await authProvider.login('bademail', 'password123');

      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, contains('Invalid email address'));
    });

    test('Login fails for short password length', () async {
      final authProvider = AuthProvider();

      // Trigger login with short password
      final result = await authProvider.login('test@example.com', '123');

      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(
        authProvider.errorMessage,
        contains('Password must be at least 6 characters'),
      );
    });

    test('Signup fails for invalid signup parameters', () async {
      final authProvider = AuthProvider();

      // Short password signup
      final result = await authProvider.signUp(
        email: 'test@example.com',
        password: '123',
        name: 'John',
        username: 'john',
        age: 25,
        country: 'United States',
        habits: [],
      );

      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(
        authProvider.errorMessage,
        contains('Password must be at least 6 characters'),
      );
    });

    test('Signup fails for empty name field', () async {
      final authProvider = AuthProvider();

      // Empty name signup
      final result = await authProvider.signUp(
        email: 'test@example.com',
        password: 'password123',
        name: '',
        username: 'john',
        age: 25,
        country: 'United States',
        habits: [],
      );

      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, contains('Name cannot be empty'));
    });
  });
}
