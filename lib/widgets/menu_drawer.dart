import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/configure_habits_screen.dart';
import '../screens/personal_info_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/detail_screen.dart';
import '../theme/theme.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header matching menu.png
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Drawer List Items
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black87),
            title: const Text('Configure', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConfigureHabitsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black87),
            title: const Text('Personal Info', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.black87),
            title: const Text('Reports', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Detail Screen showing reports
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetailScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.black87),
            title: const Text('Notifications', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black87),
            title: const Text('Sign Out', style: TextStyle(fontSize: 16)),
            onTap: () async {
              Navigator.pop(context);
              await authProvider.logout();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
