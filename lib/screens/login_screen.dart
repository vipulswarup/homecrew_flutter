import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.auth,
    required this.onLoggedIn,
  });
  final AuthService auth;
  final VoidCallback onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";
  bool isLoading = false;
  String? submitError;

  String? get emailError {
    if (email.isEmpty) {
      return 'Email is required';
    }
    return null;
  }

  String? get passwordError {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submitLogin() async {
    setState(() {
      isLoading = true;
      submitError = null;
    });

    try {
      await widget.auth.login(email: email, password: password);
      if (!mounted) return;
      widget.onLoggedIn();
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : e.toString();
      setState(() {
        submitError = message;
      });
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormValid =
        email.isNotEmpty &&
        password.isNotEmpty &&
        emailError == null &&
        passwordError == null;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Email",
                errorText: emailError,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Password",
                errorText: passwordError,
              ),
            ),
            const SizedBox(height: 16.0),
            if (submitError != null) ...[
              Text(
                submitError!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16.0),
            ],

            ElevatedButton(
              onPressed: (!isFormValid || isLoading) ? null : _submitLogin,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Login"),
            ),
            const SizedBox(height: 12.0),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(auth: widget.auth),
                        ),
                      );
                    },
              child: const Text('Create account'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              VerifyEmailScreen(auth: widget.auth),
                        ),
                      );
                    },
              child: const Text('Verify email (token)'),
            ),
          ],
        ),
      ),
    );
  }
}