import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // This line removes the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Password Generator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: const Color(0xFF2C2C2C),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const PasswordGeneratorScreen(),
    );
  }
}

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String _generatedPassword = 'Tap GENERATE';
  double _passwordLength = 12.0;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  // State variables for password strength
  String _passwordStrength = 'Weak';
  Color _strengthColor = Colors.red;

  // --- IMPROVEMENT 1: Generate a password on startup ---
  @override
  void initState() {
    super.initState();
  }

  // --- IMPROVEMENT 3: Password Strength Checker ---
  void _checkPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 16) {
      score += 3;
    } else if (password.length >= 12) {
      score += 2;
    } else if (password.length >= 8) {
      score += 1;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    setState(() {
      if (score >= 6) {
        _passwordStrength = 'Very Strong';
        _strengthColor = Colors.green;
      } else if (score >= 4) {
        _passwordStrength = 'Strong';
        _strengthColor = Colors.lightGreen;
      } else if (score >= 3) {
        _passwordStrength = 'Medium';
        _strengthColor = Colors.orange;
      } else {
        _passwordStrength = 'Weak';
        _strengthColor = Colors.red;
      }
    });
  }

  // --- IMPROVEMENT 2: Ensure Character Variety ---
  void _generatePassword() {
    const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numberChars = '0123456789';
    const String symbolChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    List<String> passwordChars = [];
    final Random random = Random.secure();

    if (_includeLowercase) {
      chars += lowercaseChars;
      passwordChars.add(lowercaseChars[random.nextInt(lowercaseChars.length)]);
    }
    if (_includeUppercase) {
      chars += uppercaseChars;
      passwordChars.add(uppercaseChars[random.nextInt(uppercaseChars.length)]);
    }
    if (_includeNumbers) {
      chars += numberChars;
      passwordChars.add(numberChars[random.nextInt(numberChars.length)]);
    }
    if (_includeSymbols) {
      chars += symbolChars;
      passwordChars.add(symbolChars[random.nextInt(symbolChars.length)]);
    }

    if (chars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one character type.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int remainingLength = _passwordLength.toInt() - passwordChars.length;
    for (int i = 0; i < remainingLength; i++) {
      passwordChars.add(chars[random.nextInt(chars.length)]);
    }

    passwordChars.shuffle(random);

    setState(() {
      _generatedPassword = passwordChars.join();
      _checkPasswordStrength(
        _generatedPassword,
      ); // Check strength of new password
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display Password
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SelectableText(
                        // Using SelectableText is also a good UX choice
                        _generatedPassword,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyToClipboard,
                      tooltip: 'Copy to Clipboard',
                    ),
                  ],
                ),
              ),
            ),

            // --- NEW: Strength Indicator UI ---
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_passwordStrength == 'Weak'
                        ? 0.25
                        : _passwordStrength == 'Medium'
                        ? 0.5
                        : _passwordStrength == 'Strong'
                        ? 0.75
                        : 1.0),
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _passwordStrength,
                  style: TextStyle(
                    color: _strengthColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Settings Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Length: ${_passwordLength.toInt()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: _passwordLength,
                      min: 4,
                      max: 32,
                      divisions: 28,
                      label: _passwordLength.toInt().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _passwordLength = value;
                        });
                      },
                    ),
                    const Divider(),

                    // Checkboxes
                    CheckboxListTile(
                      title: const Text('Include Uppercase (A-Z)'),
                      value: _includeUppercase,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeUppercase = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Include Lowercase (a-z)'),
                      value: _includeLowercase,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeLowercase = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Include Numbers (0-9)'),
                      value: _includeNumbers,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeNumbers = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Include Symbols (!@#\$)'),
                      value: _includeSymbols,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeSymbols = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Generate Button
            ElevatedButton(
              onPressed: _generatePassword,
              child: const Text('GENERATE'),
            ),
          ],
        ),
      ),
    );
  }
}
