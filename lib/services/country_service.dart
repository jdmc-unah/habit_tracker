import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CountryService {
  static const String baseUrl = 'https://api.restcountries.com/countries/v5';
  static const String apiKey = 'rc_live_88dd13be4d3349a9ae43970631f2c66a';

  // Default list of countries to fall back on, ensuring the app dropdown has
  // a list of options when running with the limited demo API key.
  static const List<String> defaultCountries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Japan',
    'Australia',
    'Mexico',
    'Colombia',
  ];

  /// Fetches the list of country names from the REST Countries API.
  /// Merges the results with the default list and returns them sorted.
  Future<List<String>> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      debugPrint('REST Countries API Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final Map<String, dynamic>? dataMap = decoded['data'] as Map<String, dynamic>?;
        
        if (dataMap != null && dataMap['objects'] != null) {
          final List<dynamic> objects = dataMap['objects'] as List<dynamic>;
          
          final List<String> apiCountries = objects.map((obj) {
            final names = obj['names'] as Map<String, dynamic>?;
            return names?['common'] as String? ?? '';
          }).where((name) => name.isNotEmpty).toList();

          if (apiCountries.isEmpty) {
            return defaultCountries;
          }

          // Merge with default list using a Set for uniqueness, then sort alphabetically
          final Set<String> mergedCountries = {...apiCountries, ...defaultCountries};
          final List<String> sortedCountries = mergedCountries.toList()..sort();
          return sortedCountries;
        }
      }
      debugPrint('Failed to load countries: Status code ${response.statusCode}');
      return defaultCountries;
    } catch (e) {
      debugPrint('Error fetching countries from RestCountries API: $e');
      return defaultCountries;
    }
  }
}
