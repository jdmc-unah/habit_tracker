import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _habitsKey = 'user_habits_list';
  static const String _profileKey = 'user_profile_data';

  // ----------------------------------------------------
  // HABITS CRUD
  // ----------------------------------------------------

  // Create or Update
  Future<void> saveHabits(List<HabitModel> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(
      habits.map((habit) => habit.toJson()).toList(),
    );
    await prefs.setString(_habitsKey, jsonString);
  }

  // Read
  Future<List<HabitModel>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_habitsKey);
    if (jsonString == null) {
      return [];
    }
    try {
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList.map((item) => HabitModel.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // Helper to add a single habit
  Future<void> addHabit(HabitModel habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  // Helper to update a single habit
  Future<void> updateHabit(HabitModel updatedHabit) async {
    final habits = await loadHabits();
    final int index = habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      habits[index] = updatedHabit;
      await saveHabits(habits);
    }
  }

  // Helper to delete a single habit
  Future<void> deleteHabit(String habitId) async {
    final habits = await loadHabits();
    habits.removeWhere((h) => h.id == habitId);
    await saveHabits(habits);
  }

  // Helper to clear all habit data
  Future<void> clearHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_habitsKey);
  }

  // ----------------------------------------------------
  // USER PROFILE persistence (Backup/Integrate)
  // ----------------------------------------------------

  Future<void> saveUserProfile(UserModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(profile.toJson()));
  }

  Future<UserModel?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_profileKey);
    if (jsonString == null) return null;
    try {
      return UserModel.fromJson(json.decode(jsonString));
    } catch (_) {
      return null;
    }
  }
}
