import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const HomeCrewApp());
}

class Household {
  final String id;
  final String name;
  final String type;

  Household({required this.id, required this.name, required this.type});
}

class Staff {
  final String id;
  final String householdId;
  final String name;
  final String role;

  final String? nickname;
  final DateTime startDate;
  final int totalLeaveAllocated;
  final List<String> agreedDuties;

  Staff({
    required this.id,
    required this.householdId,
    required this.name,
    required this.role,
    this.nickname,
    required this.startDate,
    required this.totalLeaveAllocated,
    required this.agreedDuties,
  });

  Staff copyWith({
    String? nickname,
    String? role,
    DateTime? startDate,
    int? totalLeaveAllocated,
    List<String>? agreedDuties,
  }) {
    return Staff(
      id: id,
      householdId: householdId,
      name: name,
      role: role ?? this.role,
      nickname: nickname,
      startDate: startDate ?? this.startDate,
      totalLeaveAllocated: totalLeaveAllocated ?? this.totalLeaveAllocated,
      agreedDuties: agreedDuties ?? this.agreedDuties,
    );
  }
}

final List<Staff> dummyStaff = [
  Staff(
    id: 's1',
    householdId: '1',
    name: 'Ramesh Kumar',
    nickname: 'Ramu',
    role: 'Cook',
    startDate: DateTime(2022, 3, 1),
    totalLeaveAllocated: 18,
    agreedDuties: ['Cook', 'Clean', 'Wash'],
  ),
  Staff(
    id: 's2',
    householdId: '1',
    name: 'Sita Devi',
    nickname: null,
    role: 'Cleaner',
    startDate: DateTime(2021, 7, 15),
    totalLeaveAllocated: 12,
    agreedDuties: ['Clean', 'Wash', 'Iron'],
  ),
  Staff(
    id: 's3',
    householdId: '2',
    name: 'Amit Singh',
    nickname: null,
    role: 'Security',
    startDate: DateTime(2020, 1, 10),
    totalLeaveAllocated: 24,
    agreedDuties: ['Security', 'Clean', 'Wash'],
  ),
];

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

class AppShellScreen extends StatelessWidget {
  AppShellScreen({super.key, required this.title, required this.onLogout});

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
          IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
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
        username.isNotEmpty &&
        password.isNotEmpty &&
        usernameError == null &&
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
                  username = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Username",
                errorText: usernameError,
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
  StaffListScreen({
    super.key,
    required this.householdId,
    required this.householdName,
  });

  final String householdId;
  final String householdName;

  @override
  Widget build(BuildContext context) {
    final List<Staff> staffForHousehold = dummyStaff
        .where((s) => s.householdId == householdId)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(householdName)),
      body: staffForHousehold.isEmpty
          ? Center(
              child: Text(
                'No staff members added yet.\nAdd your first staff member.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: staffForHousehold.length,
              itemBuilder: (context, index) {
                final staff = staffForHousehold[index];

                return ListTile(
                  title: Text(staff.name),
                  subtitle: Text(staff.role),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            StaffDetailsScreen(staffId: staff.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class StaffDetailsScreen extends StatefulWidget {
  const StaffDetailsScreen({
    super.key,
    required this.staffId,
  });

  final String staffId;

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  @override
Widget build(BuildContext context) {
  final staff = dummyStaff.firstWhere(
    (s) => s.id == widget.staffId,
  );

  return Scaffold(
    appBar: AppBar(
      title: const Text('Staff Details'),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final updatedStaff =
                await Navigator.of(context).push<Staff>(
              MaterialPageRoute(
                builder: (context) => EditStaffScreen(staff: staff),
              ),
            );

            if (updatedStaff != null) {
              setState(() {
                final index =
                    dummyStaff.indexWhere((s) => s.id == staff.id);
                if (index != -1) {
                  dummyStaff[index] = updatedStaff;
                }
              });
            }
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            staff.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          // Nickname (optional)
          if (staff.nickname != null) ...[
            const SizedBox(height: 4),
            Text('Nickname: ${staff.nickname}'),
          ],

          const SizedBox(height: 8),

          // Role
          Text(
            staff.role,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 16),

          // Start date
          Text('Joined on: ${_formatDate(staff.startDate)}'),

          const SizedBox(height: 8),

          // Leave allocation
          Text(
            'Total Leave Allocated: ${staff.totalLeaveAllocated} days',
          ),

          const SizedBox(height: 24),

          // Duties
          const Text(
            'Agreed Duties',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final duty in staff.agreedDuties)
            Text('• $duty'),
        ],
      ),
    ),
  );
}
}

class EditStaffScreen extends StatefulWidget {
  const EditStaffScreen({super.key, required this.staff});
  final Staff staff;

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}
class _EditStaffScreenState extends State<EditStaffScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Staff')),
      body: const Center(child: Text('Edit form goes here')),
    );
  }
}