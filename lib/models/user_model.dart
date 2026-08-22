class UserModel {
  final String name;
  final String email;
  final String username;
  final int age;
  final String country;
  final List<String> selectedHabits;

  UserModel({
    required this.name,
    required this.email,
    required this.username,
    required this.age,
    required this.country,
    List<String>? selectedHabits,
  }) : selectedHabits = selectedHabits ?? [];

  UserModel copyWith({
    String? name,
    String? email,
    String? username,
    int? age,
    String? country,
    List<String>? selectedHabits,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      age: age ?? this.age,
      country: country ?? this.country,
      selectedHabits: selectedHabits ?? this.selectedHabits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'age': age,
      'country': country,
      'selectedHabits': selectedHabits,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      age: json['age'] as int? ?? 25,
      country: json['country'] as String? ?? 'United States',
      selectedHabits: List<String>.from(json['selectedHabits'] ?? []),
    );
  }
}
