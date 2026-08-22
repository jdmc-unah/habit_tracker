import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';

class AuthService {
  static bool _useFirebase = false;

  // Track if Firebase is successfully configured
  static void setUseFirebase(bool useFb) {
    _useFirebase = useFb;
  }

  static bool get isFirebaseEnabled => _useFirebase;

  // Stream controller to broadcast auth state changes
  final StreamController<UserModel?> _authStreamController =
      StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get onAuthStateChanged => _authStreamController.stream;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Load the persisted session on startup
  Future<UserModel?> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');

    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(json.decode(userJson));
        _authStreamController.add(_currentUser);
        return _currentUser;
      } catch (_) {
        await prefs.remove('current_user');
      }
    }

    _authStreamController.add(null);
    return null;
  }

  Future<UserModel> signIn(String email, String password) async {
    // Basic format validation
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address format.');
    }
    if (password.isEmpty || password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    if (_useFirebase) {
      try {
        final credential = await fb.FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // In Firebase mode, load/mock the UserModel based on firebase user
        final prefs = await SharedPreferences.getInstance();
        final storedUserJson = prefs.getString(
          'user_profile_${credential.user?.uid}',
        );

        if (storedUserJson != null) {
          _currentUser = UserModel.fromJson(json.decode(storedUserJson));
        } else {
          _currentUser = UserModel(
            name: credential.user?.displayName ?? 'Firebase User',
            email: credential.user?.email ?? email,
            username: email.split('@')[0],
            age: 25,
            country: 'United States',
          );
        }

        await prefs.setString(
          'current_user',
          json.encode(_currentUser!.toJson()),
        );
        _authStreamController.add(_currentUser);
        return _currentUser!;
      } on fb.FirebaseException catch (e) {
        throw Exception(e.message ?? 'Firebase sign in failed.');
      }
    } else {
      // Mock Authentication Flow
      final prefs = await SharedPreferences.getInstance();
      final usersDbJson = prefs.getString('mock_users_db') ?? '{}';
      final Map<String, dynamic> usersDb = json.decode(usersDbJson);

      if (!usersDb.containsKey(email)) {
        throw Exception('No user found with this email. Please sign up.');
      }

      final userData = usersDb[email] as Map<String, dynamic>;
      if (userData['password'] != password) {
        throw Exception('Incorrect password. Please try again.');
      }

      _currentUser = UserModel.fromJson(userData['profile']);
      await prefs.setString(
        'current_user',
        json.encode(_currentUser!.toJson()),
      );
      _authStreamController.add(_currentUser);
      return _currentUser!;
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
    required int age,
    required String country,
    required List<String> habits,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email.');
    }
    if (password.isEmpty || password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }
    if (name.isEmpty) {
      throw Exception('Name cannot be empty.');
    }
    if (username.isEmpty) {
      throw Exception('Username cannot be empty.');
    }

    final newUser = UserModel(
      name: name,
      email: email,
      username: username,
      age: age,
      country: country,
      selectedHabits: habits,
    );

    if (_useFirebase) {
      try {
        final credential = await fb.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        await credential.user?.updateDisplayName(name);

        // Save user profile settings locally associated with firebase UID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'user_profile_${credential.user?.uid}',
          json.encode(newUser.toJson()),
        );
        await prefs.setString('current_user', json.encode(newUser.toJson()));

        _currentUser = newUser;
        _authStreamController.add(_currentUser);
        return _currentUser!;
      } on fb.FirebaseException catch (e) {
        throw Exception(e.message ?? 'Firebase sign up failed.');
      }
    } else {
      // Mock Sign Up Flow
      final prefs = await SharedPreferences.getInstance();
      final usersDbJson = prefs.getString('mock_users_db') ?? '{}';
      final Map<String, dynamic> usersDb = json.decode(usersDbJson);

      if (usersDb.containsKey(email)) {
        throw Exception('An account already exists with this email address.');
      }

      usersDb[email] = {'password': password, 'profile': newUser.toJson()};

      await prefs.setString('mock_users_db', json.encode(usersDb));
      await prefs.setString('current_user', json.encode(newUser.toJson()));

      _currentUser = newUser;
      _authStreamController.add(_currentUser);
      return _currentUser!;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');

    if (_useFirebase) {
      await fb.FirebaseAuth.instance.signOut();
    }

    _currentUser = null;
    _authStreamController.add(null);
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = updatedUser;
    await prefs.setString('current_user', json.encode(updatedUser.toJson()));

    if (!_useFirebase) {
      // Update in Mock DB as well
      final usersDbJson = prefs.getString('mock_users_db') ?? '{}';
      final Map<String, dynamic> usersDb = json.decode(usersDbJson);
      if (usersDb.containsKey(updatedUser.email)) {
        usersDb[updatedUser.email]['profile'] = updatedUser.toJson();
        await prefs.setString('mock_users_db', json.encode(usersDb));
      }
    } else {
      // Update in Firebase user locally
      final user = fb.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(updatedUser.name);
        await prefs.setString(
          'user_profile_${user.uid}',
          json.encode(updatedUser.toJson()),
        );
      }
    }

    _authStreamController.add(_currentUser);
  }
}
