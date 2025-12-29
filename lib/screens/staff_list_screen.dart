import 'package:flutter/material.dart';

import '../models/staff.dart';
import '../services/dummy_data.dart';
import 'staff_details_screen.dart';

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