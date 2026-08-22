import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habit_model.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  // Toggle flags for testing/evaluation of UI states
  static bool simulateError = false;
  static bool simulateEmpty = false;
  static bool simulateSlowLoad = false;

  Future<List<HabitModel>> fetchHabitsFromApi() async {
    if (simulateSlowLoad) {
      await Future.delayed(const Duration(seconds: 3));
    }

    if (simulateError) {
      throw Exception('Failed to connect to the server. (Simulated API error)');
    }

    if (simulateEmpty) {
      return [];
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl?_limit=5'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<String> colors = ['Amber', 'Green', 'Purple'];

        return data.map((jsonItem) {
          final int id = jsonItem['id'] as int;
          final String title = jsonItem['title'] as String;
          final bool completed = jsonItem['completed'] as bool? ?? false;

          return HabitModel(
            id: 'api_$id',
            name: title.toUpperCase(),
            colorName: colors[id % colors.length],
            isCompleted: completed,
            completedDates: completed
                ? [DateTime.now().toIso8601String().split('T')[0]]
                : [],
          );
        }).toList();
      } else {
        throw Exception(
          'Server responded with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // In case of real offline/network error, rethrow or fall back gracefully
      throw Exception('Network error: $e');
    }
  }
}
