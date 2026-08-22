import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../services/analytics_service.dart';
import '../theme/theme.dart';

class DetailScreen extends StatefulWidget {
  final HabitModel? habit;

  const DetailScreen({Key? key, this.habit}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late HabitModel? _activeHabit;

  @override
  void initState() {
    super.initState();
    _activeHabit = widget.habit;

    // Log event that detail is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analytics = AnalyticsService();
      analytics.logEvent('detail_opened', {
        'habit_id': _activeHabit?.id ?? 'all',
        'habit_name': _activeHabit?.name ?? 'all_habits_dashboard',
      });
    });
  }

  Color _getHabitColor(String colorName) {
    return AppTheme.habitColors[colorName] ?? AppTheme.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final allHabits = habitProvider.habits;

    // Fallback if opened from drawer and no habit is selected yet
    if (_activeHabit == null && allHabits.isNotEmpty) {
      _activeHabit = allHabits.first;
    }

    final habit = _activeHabit != null
        ? habitProvider.habits.firstWhere(
            (h) => h.id == _activeHabit!.id,
            orElse: () => _activeHabit!,
          )
        : null;

    final hasHabits = habit != null;

    // Statistics calculations
    final int totalCompletions = habit?.completedDates.length ?? 0;

    // Calculate simple streak (number of consecutive days completed up to today)
    int currentStreak = 0;
    if (hasHabits && habit.completedDates.isNotEmpty) {
      final sortedDates = List<String>.from(habit.completedDates)
        ..sort((a, b) => b.compareTo(a));
      final todayString = DateTime.now().toIso8601String().split('T')[0];

      bool completedToday = sortedDates.contains(todayString);
      if (completedToday) {
        currentStreak = 1;
        DateTime checkDate = DateTime.now().subtract(const Duration(days: 1));
        while (true) {
          final checkStr = checkDate.toIso8601String().split('T')[0];
          if (sortedDates.contains(checkStr)) {
            currentStreak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(hasHabits ? habit.name.toUpperCase() : 'Reports Dashboard'),
      ),
      body: hasHabits
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dropdown selection to switch habits in detail view
                  if (allHabits.length > 1) ...[
                    const Text(
                      'Switch Habit View:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HabitModel>(
                          value: allHabits.firstWhere(
                            (h) => h.id == habit.id,
                            orElse: () => allHabits.first,
                          ),
                          isExpanded: true,
                          items: allHabits.map((h) {
                            return DropdownMenuItem<HabitModel>(
                              value: h,
                              child: Text(h.name),
                            );
                          }).toList(),
                          onChanged: (selected) {
                            if (selected != null) {
                              setState(() {
                                _activeHabit = selected;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Color Badge Card
                  Card(
                    color: _getHabitColor(habit.colorName),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            habit.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Color Theme: ${habit.colorName}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Total Checks',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$totalCompletions',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: _getHabitColor(habit.colorName),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Current Streak',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$currentStreak Days',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: _getHabitColor(habit.colorName),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Detail Action Card (Core Requirement: Include a clear navigation/detail action)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Action Center',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Quickly toggle today\'s completion state directly from this details window.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getHabitColor(habit.colorName),
                              foregroundColor: Colors.white,
                            ),
                            icon: Icon(
                              habit.isCompleted
                                  ? Icons.undo
                                  : Icons.check_circle,
                            ),
                            label: Text(
                              habit.isCompleted
                                  ? 'Mark as Incomplete'
                                  : 'Mark as Complete Today',
                            ),
                            onPressed: () {
                              habitProvider.toggleHabitCompletion(habit.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // History Section
                  const Text(
                    'History Log',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  habit.completedDates.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'No completion history logged yet. Complete the habit on the home screen to log dates!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: habit.completedDates.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final dateStr = habit.completedDates[idx];
                              return ListTile(
                                leading: Icon(
                                  Icons.check_circle,
                                  color: _getHabitColor(habit.colorName),
                                ),
                                title: Text(dateStr),
                                subtitle: const Text('Successfully completed'),
                              );
                            },
                          ),
                        ),
                ],
              ),
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Active Habits',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Add or configure habits first from the side menu to view details and reports.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
