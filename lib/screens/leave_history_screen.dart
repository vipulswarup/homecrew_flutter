import 'package:flutter/material.dart';
import '../models/leave_entry.dart';
import '../services/dummy_data.dart';
import '../utils/leave_utils.dart';

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  final String staffId;
  final String staffName;

  @override
  Widget build(BuildContext context) {
    final staffLeaves = dummyLeaves.where((l) => l.staffId == staffId).toList();


    return Scaffold(
      appBar: AppBar(title: Text('$staffName — Leave History')),
      body: staffLeaves.isEmpty
          ? const Center(child: Text('No leave records yet'))
          : ListView.builder(
              itemCount: staffLeaves.length,
              itemBuilder: (context, index) {
                final leave = staffLeaves[index];

                return ListTile(
                  title: Text(
                    '${formatDate(leave.startDate)} → ${formatDate(leave.endDate)}',
                  ),
                  subtitle: Text(
                    leave.status == LeaveStatus.taken ? 'Taken' : 'Requested',
                  ),
                  trailing: Text(
                    '${countDaysForEntry(leave).toStringAsFixed(1)} d',
                  ),
                );
              },
            ),
    );
  }
}