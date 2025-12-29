import 'package:flutter/material.dart';

import '../models/staff.dart';
import '../models/leave_entry.dart';
import '../services/dummy_data.dart';
import 'edit_staff_screen.dart';
import 'leave_history_screen.dart';
import '../utils/leave_utils.dart';

class StaffDetailsScreen extends StatefulWidget {
  const StaffDetailsScreen({super.key, required this.staffId});

  final String staffId;

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {


  @override
  Widget build(BuildContext context) {
    final staff = dummyStaff.firstWhere((s) => s.id == widget.staffId);
    final staffLeaves = dummyLeaves
        .where((l) => l.staffId == staff.id)
        .toList();
    final takenDays = staffLeaves
        .where((l) => l.status == LeaveStatus.taken)
        .fold<double>(0.0, (sum, l) => sum + countDaysForEntry(l));

    final requestedDays = staffLeaves
        .where((l) => l.status == LeaveStatus.requested)
        .fold<double>(0.0, (sum, l) => sum + countDaysForEntry(l));

    final allocated = staff.totalLeaveAllocated.toDouble();
    final balance = allocated - takenDays;
    final overshoot = balance < 0 ? balance.abs() : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedStaff = await Navigator.of(context).push<Staff>(
                MaterialPageRoute(
                  builder: (context) => EditStaffScreen(staff: staff),
                ),
              );

              if (updatedStaff != null) {
                setState(() {
                  final index = dummyStaff.indexWhere((s) => s.id == staff.id);
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
            Text(staff.name, style: Theme.of(context).textTheme.headlineMedium),

            // Nickname (optional)
            if (staff.nickname != null) ...[
              const SizedBox(height: 4),
              Text('Nickname: ${staff.nickname}'),
            ],

            const SizedBox(height: 8),

            // Role
            Text(staff.role, style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 16),

            // Start date
            Text('Joined on: ${formatDate(staff.startDate)}'),

            const SizedBox(height: 8),

            // Leave allocation
            Text('Total Leave Allocated: ${staff.totalLeaveAllocated} days'),

            const SizedBox(height: 24),

            // Duties
            const Text(
              'Agreed Duties',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final duty in staff.agreedDuties) Text('• $duty'),

            const SizedBox(height: 24),

            const Text(
              'Leave Summary',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LeaveHistoryScreen(
                      staffId: staff.id,
                      staffName: staff.name,
                    ),
                  ),
                );
              },
              child: const Text('View Leave History'),
            ),

            const SizedBox(height: 8),

            Text('Total Allocated: ${allocated.toStringAsFixed(1)} days'),
            Text('Taken: ${takenDays.toStringAsFixed(1)} days'),
            Text(
              'Requested (upcoming): ${requestedDays.toStringAsFixed(1)} days',
            ),

            const SizedBox(height: 8),

            if (balance >= 0)
              Text('Balance: ${balance.toStringAsFixed(1)} days')
            else
              Text(
                'Overshoot: ${overshoot.toStringAsFixed(1)} days',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}