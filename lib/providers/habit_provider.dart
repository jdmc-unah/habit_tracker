import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../repositories/habit_repository.dart';
import '../services/analytics_service.dart';

class HabitProvider with ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  final AnalyticsService _analytics = AnalyticsService();

  List<HabitModel> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter lists based on today's completion status
  List<HabitModel> get todoHabits =>
      _habits.where((h) => !_isCompletedToday(h)).toList();
  List<HabitModel> get doneHabits =>
      _habits.where((h) => _isCompletedToday(h)).toList();

  String _getTodayString() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  bool _isCompletedToday(HabitModel habit) {
    final today = _getTodayString();
    return habit.completedDates.contains(today);
  }

  Future<void> fetchHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _repository.getHabits();
      // Ensure the isCompleted flag matches today's status in loaded habits
      _habits = loaded.map((h) {
        final completed = _isCompletedToday(h);
        return h.copyWith(isCompleted: completed);
      }).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncWithApi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _repository.forceSyncFromApi();
      _habits = loaded.map((h) {
        final completed = _isCompletedToday(h);
        return h.copyWith(isCompleted: completed);
      }).toList();
      await _analytics.logEvent('habits_synced_api', {'count': _habits.length});
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(String name, String colorName) async {
    if (name.trim().isEmpty) return;

    final id =
        'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100)}';
    final newHabit = HabitModel(
      id: id,
      name: name.trim(),
      colorName: colorName,
      isCompleted: false,
      completedDates: [],
    );

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.saveHabit(newHabit);
      _habits.add(newHabit);
      await _analytics.logEvent('habit_created', {
        'name': name,
        'color': colorName,
      });
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final habit = _habits[index];
    final today = _getTodayString();
    final List<String> updatedDates = List.from(habit.completedDates);
    bool nowCompleted = false;

    if (updatedDates.contains(today)) {
      updatedDates.remove(today);
      nowCompleted = false;
    } else {
      updatedDates.add(today);
      nowCompleted = true;
    }

    final updatedHabit = habit.copyWith(
      isCompleted: nowCompleted,
      completedDates: updatedDates,
    );

    _habits[index] = updatedHabit;
    notifyListeners(); // Immediate local UI update

    try {
      await _repository.updateHabit(updatedHabit);
      await _analytics.logEvent('habit_completion_toggled', {
        'id': id,
        'name': habit.name,
        'completed': nowCompleted,
      });
    } catch (e) {
      // Revert if DB fails
      _habits[index] = habit;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final habit = _habits[index];
    _habits.removeAt(index);
    notifyListeners();

    try {
      await _repository.deleteHabit(id);
      await _analytics.logEvent('habit_deleted', {
        'id': id,
        'name': habit.name,
      });
    } catch (e) {
      // Revert if DB fails
      _habits.insert(index, habit);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> resetAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.clearAll();
      _habits.clear();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
