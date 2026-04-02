import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'api/token_store.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HomeCrewApp());
}

class HomeCrewApp extends StatefulWidget {
  const HomeCrewApp({super.key});

  @override
  State<HomeCrewApp> createState() => _HomeCrewAppState();
}

class _HomeCrewAppState extends State<HomeCrewApp> {
  final TokenStore _tokenStore = TokenStore();
  late final ApiClient _api = ApiClient(
    tokenStore: _tokenStore,
    refresh: (refreshToken) => AuthService.refreshTokens(_api, refreshToken),
  );
  late final AuthService _auth = AuthService(api: _api, tokenStore: _tokenStore);

  bool _isBootstrapping = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _bootstrapSession();
  }

  Future<void> _bootstrapSession() async {
    final pair = await _tokenStore.read();
    if (pair == null) {
      setState(() {
        _isBootstrapping = false;
        _isLoggedIn = false;
      });
      return;
    }

    try {
      await _auth.me();
      setState(() {
        _isBootstrapping = false;
        _isLoggedIn = true;
      });
    } catch (_) {
      await _tokenStore.clear();
      setState(() {
        _isBootstrapping = false;
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _isBootstrapping
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _isLoggedIn
              ? HomeShellScreen(
                  auth: _auth,
                  api: _api,
                  onLoggedOut: () {
                    setState(() {
                      _isLoggedIn = false;
                    });
                  },
                )
              : LoginScreen(
                  auth: _auth,
                  onLoggedIn: () {
                    setState(() {
                      _isLoggedIn = true;
                    });
                  },
                ),
    );
  }
}