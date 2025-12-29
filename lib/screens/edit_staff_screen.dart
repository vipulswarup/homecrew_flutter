import 'package:flutter/material.dart';

import '../models/staff.dart';

class EditStaffScreen extends StatefulWidget {
  const EditStaffScreen({super.key, required this.staff});
  final Staff staff;

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  late String nickname;
  late String role;
  late String totalLeaveText;
  late String dutiesText;
  late TextEditingController nicknameController;
  late TextEditingController roleController;
  late TextEditingController totalLeaveController;
  late TextEditingController dutiesController;

  @override
  void initState() {
    super.initState();

    nicknameController = TextEditingController(
      text: widget.staff.nickname ?? '',
    );
    roleController = TextEditingController(text: widget.staff.role);
    totalLeaveController = TextEditingController(
      text: widget.staff.totalLeaveAllocated.toString(),
    );
    dutiesController = TextEditingController(
      text: widget.staff.agreedDuties.join('\n'),
    );

    roleController.addListener(() {
      setState(() {});
    });

    totalLeaveController.addListener(() {
      setState(() {});
    });

    dutiesController.addListener(() {
      setState(() {});
    });
    nicknameController.addListener(() {
      setState(() {});
    });
  }

  String? get roleError {
    if (roleController.text.trim().isEmpty) {
      return 'Role is required';
    }
    return null;
  }

  String? get leaveError {
    final value = int.tryParse(totalLeaveController.text);
    if (value == null || value < 0) {
      return 'Enter a valid number';
    }
    return null;
  }

  bool get isFormValid {
    return roleError == null && leaveError == null;
  }

  @override
  void dispose() {
    nicknameController.dispose();
    roleController.dispose();
    totalLeaveController.dispose();
    dutiesController.dispose();
    super.dispose();
  }

  void _saveStaff() {
    final updatedStaff = widget.staff.copyWith(
      nickname: nicknameController.text.trim().isEmpty
          ? null
          : nicknameController.text.trim(),
      role: roleController.text.trim(),
      totalLeaveAllocated: int.parse(totalLeaveController.text),
      agreedDuties: dutiesController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );

    Navigator.pop(context, updatedStaff);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Staff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isFormValid ? _saveStaff : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Name (read-only)
            Text(
              widget.staff.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: InputDecoration(labelText: 'Nickname'),
              controller: nicknameController,
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: InputDecoration(
                labelText: 'Role',
                errorText: roleError,
              ),
              controller: roleController,
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: InputDecoration(
                labelText: 'Total Leave Allocated',
                errorText: leaveError,
              ),
              keyboardType: TextInputType.number,
              controller: totalLeaveController,
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Agreed Duties (one per line)',
              ),
              maxLines: 5,
              controller: dutiesController,
            ),
          ],
        ),
      ),
    );
  }
}