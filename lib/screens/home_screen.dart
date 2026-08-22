import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../theme/theme.dart';
import '../widgets/menu_drawer.dart';
import 'detail_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch habits on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).fetchHabits();
    });
  }

  Color _getHabitColor(String colorName) {
    return AppTheme.habitColors[colorName] ?? AppTheme.primaryBlue;
  }

  Widget _buildHabitCard(BuildContext context, HabitModel habit, bool isDone) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final cardColor = _getHabitColor(habit.colorName);

    Widget cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              habit.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          if (isDone)
            const Icon(Icons.check_circle, color: Colors.white, size: 26),
        ],
      ),
    );

    // If already done, we just return a tappable card (no slide needed, or slide to undo)
    if (isDone) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: InkWell(
          onTap: () {
            // Track item selected & detail opened
            Provider.of<AuthProvider>(context, listen: false).clearError();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(habit: habit)),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Slidable(
            key: ValueKey('done_${habit.id}'),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.35,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    habitProvider.toggleHabitCompletion(habit.id);
                  },
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.undo,
                  label: 'to Todo',
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ],
            ),
            child: cardContent,
          ),
        ),
      );
    }

    // Slidable card for To Do items (Swipe left to complete)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(habit: habit)),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Slidable(
          key: ValueKey('todo_${habit.id}'),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.35,
            children: [
              SlidableAction(
                onPressed: (_) {
                  habitProvider.toggleHabitCompletion(habit.id);
                },
                backgroundColor: const Color(
                  0xFF76C043,
                ), // Green complete button matching screenshots
                foregroundColor: Colors.white,
                icon: Icons.check,
                label: 'to Complete',
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ],
          ),
          child: cardContent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);
    final user = authProvider.user;

    // Display Name in title (Matches home_page.png: e.g. "Test User")
    final String displayName = user?.name ?? 'Test User';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        // Menu Drawer icon on left is handled automatically by Scaffold drawer,
        // but we style it to match home_page.png
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: [
          // Refresh/Sync button to fetch API
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: () => habitProvider.syncWithApi(),
          ),
        ],
      ),
      drawer: const MenuDrawer(),
      body: Builder(
        builder: (context) {
          if (habitProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            );
          }

          // Error UX State (Matches API integration UX requirements)
          if (habitProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Sync Failed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      habitProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      onPressed: () {
                        habitProvider.fetchHabits();
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      child: const Text('Use Local Data'),
                      onPressed: () {
                        ApiService.simulateError = false;
                        habitProvider.fetchHabits();
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          final todos = habitProvider.todoHabits;
          final dones = habitProvider.doneHabits;

          // Empty State
          if (todos.isEmpty && dones.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Habits Yet!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your habit lists are currently empty. You can fetch initial tasks from the API, or add custom habits.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => habitProvider.syncWithApi(),
                      child: const Text('Fetch Initial API Todos'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => habitProvider.fetchHabits(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 16),

                // To Do Section Header (Matches home_page.png: To Do 📝)
                if (todos.isNotEmpty) ...[
                  const Center(
                    child: Text(
                      'To Do 📝',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...todos
                      .map((habit) => _buildHabitCard(context, habit, false))
                      .toList(),
                  const SizedBox(height: 24),
                ],

                // Done Section Header (Matches home_page.png: Done ✅🎉)
                if (dones.isNotEmpty) ...[
                  const Center(
                    child: Text(
                      'Done ✅🎉',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...dones
                      .map((habit) => _buildHabitCard(context, habit, true))
                      .toList(),
                  const SizedBox(height: 24),
                ],

                // Small instructional swipe text
                if (todos.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 10,
                    ),
                    child: Center(
                      child: Text(
                        'Swipe right-to-left on a habit to mark as complete',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
