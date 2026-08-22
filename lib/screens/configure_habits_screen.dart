import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../theme/theme.dart';
import '../widgets/custom_button.dart';

class ConfigureHabitsScreen extends StatefulWidget {
  const ConfigureHabitsScreen({super.key});

  @override
  State<ConfigureHabitsScreen> createState() => _ConfigureHabitsScreenState();
}

class _ConfigureHabitsScreenState extends State<ConfigureHabitsScreen> {
  final _nameController = TextEditingController();
  String _selectedColor = 'Amber';
  final _formKey = GlobalKey<FormState>();

  final List<String> _colors = ['Amber', 'Green', 'Purple', 'Teal'];

  Color _getColorValue(String colorName) {
    return AppTheme.habitColors[colorName] ?? AppTheme.primaryBlue;
  }

  void _addHabit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<HabitProvider>(context, listen: false);
      provider.addHabit(_nameController.text, _selectedColor);
      _nameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Habit added successfully!'),
          backgroundColor: _getColorValue(_selectedColor),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;

    return Scaffold(
      appBar: AppBar(title: const Text('Configure Habits')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habit Name Input (Matches configure_habits_page.png: Habit Name input border)
                  const Text(
                    'Habit Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Practice',
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF6B34B2),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF6B34B2),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryBlue,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a habit name.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Color selection label (Matches configure_habits_page.png: Select Color:)
                  const Text(
                    'Select Color:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dropdown displaying colors (Matches configure_habits_page.png color bar)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedColor,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                        items: _colors.map((colorName) {
                          final colorValue = _getColorValue(colorName);
                          return DropdownMenuItem<String>(
                            value: colorName,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colorValue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  colorName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorValue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedColor = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add Habit Button (Matches configure_habits_page.png: Add Habit blue button)
                  CustomButton(
                    text: 'Add Habit',
                    onPressed: _addHabit,
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Title for current habits list
            const Text(
              'Current Habits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Habits list with colored circles and red trash bins (Matches configure_habits_page.png)
            habits.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No habits configured yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final habit = habits[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Colored circle indicator
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _getColorValue(habit.colorName),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Habit Name
                            Expanded(
                              child: Text(
                                habit.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // Red trash icon
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                habitProvider.deleteHabit(habit.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Habit deleted persistently.',
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
