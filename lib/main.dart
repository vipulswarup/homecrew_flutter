import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/login_screen.dart';
import 'screens/household_list_screen.dart';


void main() {
  runApp(const HomeCrewApp());
}

class HomeCrewApp extends StatefulWidget {
  const HomeCrewApp({super.key});

  @override
  State<HomeCrewApp> createState() => _HomeCrewAppState();
}

class _HomeCrewAppState extends State<HomeCrewApp> {
  String? authToken;
  bool get isLoggedIn => authToken != null;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _secureStorage.read(key: 'authToken');
    setState(() {
      authToken = token;
    });
  }

  Future<void> _handleLoginSuccess() async {
    await _secureStorage.write(key: 'authToken', value: 'fake-token');

    setState(() {
      authToken = 'fake-token';
    });
  }

  Future<void> _handleLogout() async {
    await _secureStorage.delete(key: 'authToken');
    setState(() {
      authToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn
          ? AppShellScreen(
              title: 'Welcome to Home Crew',
              onLogout: _handleLogout,
            )
          : LoginScreen(onLogin: _handleLoginSuccess),
    );
  }
}