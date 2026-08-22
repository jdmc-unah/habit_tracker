import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../services/country_service.dart';
import '../widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _webAlertVisible = false;
  String _webAlertTitle = '';
  String _webAlertBody = '';

  List<String> _countries = [];
  bool _isLoadingCountries = true;

  @override
  void initState() {
    super.initState();
    // Register visual callback for web notification simulations
    NotificationService.onWebNotificationReceived = (title, body) {
      if (mounted) {
        setState(() {
          _webAlertTitle = title;
          _webAlertBody = body;
          _webAlertVisible = true;
        });
      }
    };
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final countryService = CountryService();
    final countries = await countryService.fetchCountries();
    if (mounted) {
      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
      });
    }
  }

  @override
  void dispose() {
    NotificationService.onWebNotificationReceived = null;
    super.dispose();
  }

  void _triggerTestNotification() async {
    // Request permission first
    final permissionGranted = await _notificationService.requestPermissions();
    if (permissionGranted) {
      await _notificationService.triggerTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification triggered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permission was denied.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final analyticsLogs = _analyticsService.localLog;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Notifications')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom web popup reminder alert (Simulating evidence-notification-alert.png)
            if (_webAlertVisible) ...[
              Card(
                color: Colors.amber.shade100,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.amber, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: Colors.amber,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _webAlertTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _webAlertVisible = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _webAlertBody,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Section 1: Visual Style / Theme Settings
            const Text(
              'App Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode Theme'),
                    subtitle: const Text('Toggle dark color scheme'),
                    value: settingsProvider.isDarkTheme,
                    onChanged: (val) {
                      settingsProvider.toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1.5: Profile Settings / Country selection
            const Text(
              'Profile Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Country',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingCountries
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _countries.contains(authProvider.user?.country)
                                ? authProvider.user?.country
                                : (_countries.isNotEmpty ? _countries.first : ''),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: _countries.map((country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                            onChanged: (newCountry) async {
                              if (newCountry != null &&
                                  authProvider.user != null &&
                                  newCountry != authProvider.user!.country) {
                                final updatedUser = authProvider.user!.copyWith(
                                  country: newCountry,
                                );
                                final success = await authProvider.updateProfile(updatedUser);
                                if (context.mounted && success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Country updated to $newCountry successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Local Notification Channel settings (Evidence & Configuration)
            const Text(
              'Notification Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Allow Notifications'),
                      subtitle: const Text(
                        'Enable daily habit tracker reminders',
                      ),
                      value: settingsProvider.notificationsEnabled,
                      onChanged: (val) {
                        settingsProvider.toggleNotifications(val);
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Android Channel: habitt_reminders_channel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      'Details: High priority banners, system audio alerts, and lock screen widgets.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Trigger Test Notification',
                      onPressed: _triggerTestNotification,
                      backgroundColor: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Live Analytics Event logs
            const Text(
              'Live Analytics Logs (Tracked)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            analyticsLogs.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No analytics events tracked in this session yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: analyticsLogs.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final log =
                            analyticsLogs[analyticsLogs.length - 1 - idx];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.analytics,
                            color: Colors.blue,
                          ),
                          title: Text(log['name']),
                          subtitle: Text(log['parameters'].toString()),
                          trailing: Text(
                            log['timestamp'].toString().substring(11, 19),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 32),

            // Section 4: Authentication Actions
            CustomButton(
              text: 'Logout Session',
              onPressed: () async {
                Navigator.pop(context); // Pop settings screen first
                await authProvider
                    .logout(); // Trigger logout which updates main.dart root screen
              },
              backgroundColor: Colors.redAccent,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
