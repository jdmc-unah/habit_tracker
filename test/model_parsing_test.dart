import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_project/models/habit_model.dart';
import 'package:capstone_project/models/user_model.dart';

void main() {
  group('HabitModel Parsing Tests', () {
    test('Should parse HabitModel from JSON correctly', () {
      final jsonMap = {
        'id': 'api_1',
        'name': 'DRINK WATER',
        'colorName': 'Amber',
        'isCompleted': true,
        'completedDates': ['2026-08-22'],
      };

      final habit = HabitModel.fromJson(jsonMap);

      expect(habit.id, 'api_1');
      expect(habit.name, 'DRINK WATER');
      expect(habit.colorName, 'Amber');
      expect(habit.isCompleted, true);
      expect(habit.completedDates, ['2026-08-22']);
    });

    test('Should convert HabitModel to JSON correctly', () {
      final habit = HabitModel(
        id: 'local_123',
        name: 'RUN 5K',
        colorName: 'Green',
        isCompleted: false,
        completedDates: ['2026-08-21'],
      );

      final jsonMap = habit.toJson();

      expect(jsonMap['id'], 'local_123');
      expect(jsonMap['name'], 'RUN 5K');
      expect(jsonMap['colorName'], 'Green');
      expect(jsonMap['isCompleted'], false);
      expect(jsonMap['completedDates'], ['2026-08-21']);
    });
  });

  group('UserModel Parsing Tests', () {
    test('Should parse UserModel from JSON correctly', () {
      final jsonMap = {
        'name': 'John Smith',
        'email': 'john@smith.com',
        'username': 'jsmith',
        'age': 25,
        'country': 'United States',
        'selectedHabits': ['Meditate', 'Workout'],
      };

      final user = UserModel.fromJson(jsonMap);

      expect(user.name, 'John Smith');
      expect(user.email, 'john@smith.com');
      expect(user.username, 'jsmith');
      expect(user.age, 25);
      expect(user.country, 'United States');
      expect(user.selectedHabits, ['Meditate', 'Workout']);
    });

    test('Should convert UserModel to JSON correctly', () {
      final user = UserModel(
        name: 'Jane Doe',
        email: 'jane@doe.com',
        username: 'jdoe',
        age: 30,
        country: 'Canada',
        selectedHabits: ['Sleep 8 Hours'],
      );

      final jsonMap = user.toJson();

      expect(jsonMap['name'], 'Jane Doe');
      expect(jsonMap['email'], 'jane@doe.com');
      expect(jsonMap['username'], 'jdoe');
      expect(jsonMap['age'], 30);
      expect(jsonMap['country'], 'Canada');
      expect(jsonMap['selectedHabits'], ['Sleep 8 Hours']);
    });
  });
}
