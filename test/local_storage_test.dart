import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/models/habit_model.dart';
import 'package:capstone_project/services/local_storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService CRUD Tests', () {
    final service = LocalStorageService();

    test('Load habits returns empty list when no data is saved', () async {
      final habits = await service.loadHabits();
      expect(habits, isEmpty);
    });

    test('Save and Load habits returns stored list', () async {
      final list = [
        HabitModel(id: '1', name: 'TEST HABIT 1', colorName: 'Amber'),
        HabitModel(id: '2', name: 'TEST HABIT 2', colorName: 'Green'),
      ];

      await service.saveHabits(list);
      final loaded = await service.loadHabits();

      expect(loaded.length, 2);
      expect(loaded[0].name, 'TEST HABIT 1');
      expect(loaded[1].colorName, 'Green');
    });

    test('Add habit appends to list correctly', () async {
      final initial = [
        HabitModel(id: '1', name: 'TEST HABIT 1', colorName: 'Amber'),
      ];
      await service.saveHabits(initial);

      final newHabit = HabitModel(
        id: '2',
        name: 'TEST HABIT 2',
        colorName: 'Purple',
      );
      await service.addHabit(newHabit);

      final loaded = await service.loadHabits();
      expect(loaded.length, 2);
      expect(loaded[1].id, '2');
      expect(loaded[1].colorName, 'Purple');
    });

    test('Update habit modifies existing item in list', () async {
      final initial = [
        HabitModel(id: '1', name: 'TEST 1', colorName: 'Amber'),
        HabitModel(id: '2', name: 'TEST 2', colorName: 'Green'),
      ];
      await service.saveHabits(initial);

      final updated = HabitModel(
        id: '2',
        name: 'TEST 2 UPDATED',
        colorName: 'Purple',
        isCompleted: true,
      );
      await service.updateHabit(updated);

      final loaded = await service.loadHabits();
      expect(loaded.length, 2);
      expect(loaded[1].name, 'TEST 2 UPDATED');
      expect(loaded[1].colorName, 'Purple');
      expect(loaded[1].isCompleted, true);
    });

    test('Delete habit removes item from list', () async {
      final initial = [
        HabitModel(id: '1', name: 'TEST 1', colorName: 'Amber'),
        HabitModel(id: '2', name: 'TEST 2', colorName: 'Green'),
      ];
      await service.saveHabits(initial);

      await service.deleteHabit('1');

      final loaded = await service.loadHabits();
      expect(loaded.length, 1);
      expect(loaded[0].id, '2');
    });
  });
}
