import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../services/auth_service.dart';
import 'household_list_screen.dart';

class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({
    super.key,
    required this.auth,
    required this.api,
    required this.onLoggedOut,
  });

  final AuthService auth;
  final ApiClient api;
  final VoidCallback onLoggedOut;

  @override
  Widget build(BuildContext context) {
    return HouseholdListScreen(
      api: api,
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            try {
              await auth.logout();
            } finally {
              onLoggedOut();
            }
          },
        ),
      ],
    );
  }
}

