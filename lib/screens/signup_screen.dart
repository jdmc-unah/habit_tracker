import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/country_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  double _age = 25.0;
  String _selectedCountry = 'United States';
  List<String> _countries = CountryService.defaultCountries;
  bool _isLoadingCountries = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final countryService = CountryService();
    final countries = await countryService.fetchCountries();
    if (mounted) {
      setState(() {
        _countries = countries;
        if (!_countries.contains(_selectedCountry)) {
          _selectedCountry = _countries.isNotEmpty ? _countries.first : '';
        }
        _isLoadingCountries = false;
      });
    }
  }

  final List<String> _availableHabits = [
    'Wake Up Early',
    'Workout',
    'Drink Water',
    'Meditate',
    'Read a Book',
    'Practice Gratitude',
    'Sleep 8 Hours',
    'Eat Healthy',
  ];

  final Set<String> _selectedHabits = {};

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        age: _age.round(),
        country: _selectedCountry,
        habits: _selectedHabits.toList(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Welcome to Habitt.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to login screen on success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(
        0xFF0C53C5,
      ), // Solid royal blue background matching register_page.png
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error panel matching signup_error.png
              if (authProvider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => authProvider.clearError(),
                      ),
                    ],
                  ),
                ),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field (Matches register_page.png: person icon, e.g. "john smith")
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'john smith',
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFF0C53C5),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Username Field (Matches register_page.png: @ icon, e.g. "jsmith")
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
                    const SizedBox(height: 16),

                    // Email Field (Core requirement)
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.mail,
                        color: Color(0xFF0C53C5),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email.';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field (Core requirement)
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF0C53C5),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password.';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Age label and slider (Matches register_page.png: Age: 25)
                    Text(
                      'Age: ${_age.round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: _age,
                      min: 1.0,
                      max: 100.0,
                      divisions: 99,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      onChanged: (value) {
                        setState(() {
                          _age = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Country Dropdown (Matches register_page.png: United States)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedCountry,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                        icon: _isLoadingCountries
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0C53C5),
                                  ),
                                ),
                              )
                            : const Icon(
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

                    const SizedBox(height: 24),

                    // Habits selection (Matches register_page.png: Select Your Habits)
                    const Text(
                      'Select Your Habits',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableHabits.map((habit) {
                        final isSelected = _selectedHabits.contains(habit);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedHabits.remove(habit);
                              } else {
                                _selectedHabits.add(habit);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white38,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              habit,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0C53C5)
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Register/Sign Up Submit Button
              CustomButton(
                text: 'Sign Up',
                isLoading: authProvider.isLoading,
                backgroundColor: const Color(0xFF007AFF), // iOS blue accent
                onPressed: _submit,
              ),

              const SizedBox(height: 20),

              // Back to Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  GesturefulTextButton(
                    text: 'Log In',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple custom inline text button helper
class GesturefulTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GesturefulTextButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
