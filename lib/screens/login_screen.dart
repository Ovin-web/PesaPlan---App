import 'package:flutter/material.dart';
import 'package:pesaplan_new/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final Function toggleView;
  const LoginScreen({super.key, required this.toggleView});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  bool isRegisterMode = false; // ✅ NEW (does not remove anything)

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PesaPlan'),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: Text(isRegisterMode ? 'Sign In' : 'Register'),
            onPressed: () {
              setState(() {
                isRegisterMode = !isRegisterMode;
                error = '';
              });
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0),

              // EMAIL
              TextFormField(
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) => setState(() => email = val),
                decoration: const InputDecoration(hintText: 'Email'),
              ),

              const SizedBox(height: 20.0),

              // PASSWORD
              TextFormField(
                obscureText: true,
                validator: (val) =>
                val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                onChanged: (val) => setState(() => password = val),
                decoration: const InputDecoration(hintText: 'Password'),
              ),

              const SizedBox(height: 30.0),

              // MAIN BUTTON
              ElevatedButton(
                child: Text(isRegisterMode ? 'Register' : 'Sign In'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result;

                    if (isRegisterMode) {
                      result = await _auth.signUp(email, password);
                      if (result != null) {
                        _showSnack(
                          'Registration successful! Verify your email.',
                        );
                        setState(() => isRegisterMode = false);
                      }
                    } else {
                      result = await _auth.signIn(email, password);
                      if (result != null) {
                        _showSnack('Login successful');
                      }
                    }

                    if (result == null) {
                      setState(() {
                        error = isRegisterMode
                            ? 'Registration failed'
                            : 'Could not sign in with those credentials';
                      });
                      _showSnack(error, error: true);
                    }
                  }
                },
              ),

              const SizedBox(height: 12.0),

              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
