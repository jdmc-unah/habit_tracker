import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;

  double _age = 25.0;
  String _selectedCountry = 'United States';
  bool _initialized = false;

  final List<String> _countries = [
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      _nameController = TextEditingController(text: user?.name ?? '');
      _usernameController = TextEditingController(text: user?.username ?? '');
      _age = (user?.age ?? 25).toDouble();
      _selectedCountry = user?.country ?? 'United States';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        final updatedUser = user.copyWith(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          age: _age.round(),
          country: _selectedCountry,
        );

        final success = await authProvider.updateProfile(updatedUser);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Name text field (Matches personal_info.png: name label, user icon)
              CustomTextField(
                controller: _nameController,
                hintText: 'john smith',
                prefixIcon: const Icon(Icons.person, color: Color(0xFF0C53C5)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Username text field (Matches personal_info.png: username label, @ icon)
              CustomTextField(
                controller: _usernameController,
                hintText: 'jsmith',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(top: 13, left: 16, right: 10),
                  child: Text(
                    '@',
                    style: TextStyle(
                      color: Color(0xFF0C53C5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your username.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Age Text & Slider (Matches personal_info.png: Age: 25)
              Center(
                child: Text(
                  'Age: ${_age.round()}',
                  style: const TextStyle(
                    color: Color(0xFF0C53C5),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _age,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                activeColor: const Color(0xFF007AFF),
                inactiveColor: Colors.black12,
                onChanged: (value) {
                  setState(() {
                    _age = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Country Dropdown (Matches personal_info.png: United States)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black12),
                ),
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF0C53C5),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF0C53C5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCountry = val;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 36),

              // Save Changes Button (Matches personal_info.png: Save Changes button in blue)
              CustomButton(
                text: 'Save Changes',
                isLoading: authProvider.isLoading,
                backgroundColor: const Color(0xFF007AFF),
                onPressed: _saveChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
