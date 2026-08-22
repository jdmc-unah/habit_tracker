import '../models/habit_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class HabitRepository {
  final ApiService _apiService = ApiService();
  final LocalStorageService _storageService = LocalStorageService();

  Future<List<HabitModel>> getHabits() async {
    // 1. Try to load habits from local storage
    List<HabitModel> localHabits = await _storageService.loadHabits();

    // 2. If local storage is empty, fetch from API, save to local storage, and return
    if (localHabits.isEmpty) {
      try {
        final apiHabits = await _apiService.fetchHabitsFromApi();
        if (apiHabits.isNotEmpty) {
          await _storageService.saveHabits(apiHabits);
          return apiHabits;
        }
      } catch (e) {
        // Log or handle network error, return empty list or propagate
        rethrow;
      }
    }

    return localHabits;
  }

  Future<void> saveHabit(HabitModel habit) async {
    await _storageService.addHabit(habit);
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _storageService.updateHabit(habit);
  }

  Future<void> deleteHabit(String habitId) async {
    await _storageService.deleteHabit(habitId);
  }

  Future<List<HabitModel>> forceSyncFromApi() async {
    final apiHabits = await _apiService.fetchHabitsFromApi();
    await _storageService.saveHabits(apiHabits);
    return apiHabits;
  }

  Future<void> clearAll() async {
    await _storageService.clearHabits();
  }
}
