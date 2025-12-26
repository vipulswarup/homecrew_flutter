import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const HomeCrewApp());
}

class Household {
  final String id;
  final String name;
  final String type;

  Household({
    required this.id,
    required this.name,
    required this.type,
  });
}

class Staff {
  final String id;
  final String householdId;
  final String name;
  final String role;

  Staff({
    required this.id,
    required this.householdId,
    required this.name,
    required this.role,
  });
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
    await _secureStorage.write(
      key: 'authToken',
      value: 'fake-token',
    );

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



class AppShellScreen extends StatelessWidget {
  AppShellScreen({
    super.key,
    required this.title,
    required this.onLogout,
  });

  final String title;
  final VoidCallback onLogout;
  final List<Household> households = [
    Household(id: '1', name: 'Gupta Residence', type: 'Home'),
    Household(id: '2', name: 'EisenVault Office', type: 'Office'),
    Household(id: '3', name: 'Sharma Residence', type: 'Home'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: households.length,
        itemBuilder: (context, index) {
          final household = households[index];

          return ListTile(
            title: Text(household.name),
            subtitle: Text(household.type),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StaffListScreen(
                    householdId: household.id,
                    householdName: household.name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});
  final VoidCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String username = "";
  String password = "";
  bool isLoading = false;

  String? get usernameError {
    if (username.isEmpty) {
      return 'Username is required';
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
  });

  // Simulate network delay
  await Future.delayed(const Duration(seconds: 2));

  setState(() {
    isLoading = false;
  });

  widget.onLogin();
}

  @override
  Widget build(BuildContext context) {
    final bool isFormValid =
    username.isNotEmpty && password.isNotEmpty && usernameError == null && passwordError == null;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
              decoration: InputDecoration(labelText: "Username", errorText: usernameError),
            ),
            const SizedBox(height: 16.0),
            TextField(
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: InputDecoration(labelText: "Password", errorText: passwordError),
            ),
            const SizedBox(height: 16.0),
            
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
          ],
        ),
        
      ),
    );
  }
}

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({
    super.key,
    required this.householdId,
    required this.householdName,
  });

  final String householdId;
  final String householdName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(householdName),
      ),
      body: Center(
        child: Text(
          'Staff list for household ID: $householdId',
        ),
      ),
    );
  }
}