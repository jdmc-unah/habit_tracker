class HabitModel {
  final String id;
  final String name;
  final String colorName; // "Amber", "Green", "Purple", "Teal"
  final bool isCompleted; // Whether completed today
  final List<String> completedDates; // List of YYYY-MM-DD strings

  HabitModel({
    required this.id,
    required this.name,
    required this.colorName,
    this.isCompleted = false,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  HabitModel copyWith({
    String? id,
    String? name,
    String? colorName,
    bool? isCompleted,
    List<String>? completedDates,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorName: colorName ?? this.colorName,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorName': colorName,
      'isCompleted': isCompleted,
      'completedDates': completedDates,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorName: json['colorName'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDates: List<String>.from(json['completedDates'] ?? []),
    );
  }
}
