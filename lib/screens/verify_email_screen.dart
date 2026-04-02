import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String token = '';
  bool isLoading = false;
  String? submitError;
  bool verified = false;

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      submitError = null;
    });
    try {
      await widget.auth.verifyEmail(token: token);
      if (!mounted) return;
      setState(() {
        verified = true;
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
      appBar: AppBar(title: const Text('Verify email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: verified
            ? const Center(child: Text('Email verified. You can now log in.'))
            : Column(
                children: [
                  const Text(
                    'Paste the verification token to verify your account.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Token'),
                    onChanged: (v) => setState(() => token = v),
                  ),
                  const SizedBox(height: 12),
                  if (submitError != null) ...[
                    Text(submitError!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: isLoading || token.isEmpty ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify'),
                  ),
                ],
              ),
      ),
    );
  }
}

