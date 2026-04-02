import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String name = '';
  String email = '';
  String password = '';
  bool isLoading = false;
  String? submitError;
  bool submitted = false;

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      submitError = null;
    });
    try {
      await widget.auth.signup(email: email, password: password, name: name);
      if (!mounted) return;
      setState(() {
        submitted = true;
      });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: submitted
            ? const Center(
                child: Text(
                  'Account created.\nCheck your email to verify before logging in.',
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (v) => setState(() => name = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (v) => setState(() => email = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onChanged: (v) => setState(() => password = v),
                  ),
                  const SizedBox(height: 12),
                  if (submitError != null) ...[
                    Text(submitError!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
                  ),
                ],
              ),
      ),
    );
  }
}

