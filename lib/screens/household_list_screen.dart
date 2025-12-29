import 'package:flutter/material.dart';

import '../models/household.dart';
import 'staff_list_screen.dart';

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