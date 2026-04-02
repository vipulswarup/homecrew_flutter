import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/staff.dart';
import '../services/staff_service.dart';

class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({
    super.key,
    required this.staffService,
    required this.householdId,
  });

  final StaffService staffService;
  final String householdId;

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  String name = '';
  String nickname = '';
  String role = '';
  String startDateIso = '';
  String totalLeaveAllocated = '';
  String salaryAmountMonthly = '';
  String salaryEffectiveFromIso = '';
  String salaryCurrency = '';

  bool isLoading = false;
  String? submitError;

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      submitError = null;
    });

    try {
      final staff = await widget.staffService.create(
        householdId: widget.householdId,
        name: name.trim(),
        nickname: nickname.trim(),
        role: role.trim(),
        startDateIso: startDateIso.trim(),
        totalLeaveAllocated: int.parse(totalLeaveAllocated),
        salaryAmountMonthly: int.parse(salaryAmountMonthly),
        salaryEffectiveFromIso: salaryEffectiveFromIso.trim(),
        salaryCurrency: salaryCurrency.trim().isEmpty
            ? null
            : salaryCurrency.trim().toUpperCase(),
      );
      if (!mounted) return;
      Navigator.of(context).pop<Staff>(staff);
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : e.toString();
      setState(() {
        submitError = message;
      });
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = name.trim().isNotEmpty &&
        role.trim().isNotEmpty &&
        startDateIso.trim().isNotEmpty &&
        salaryEffectiveFromIso.trim().isNotEmpty &&
        int.tryParse(totalLeaveAllocated) != null &&
        int.tryParse(salaryAmountMonthly) != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Create staff')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (v) => setState(() => name = v),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Nickname'),
                onChanged: (v) => setState(() => nickname = v),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Role'),
                onChanged: (v) => setState(() => role = v),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Start date (YYYY-MM-DD)',
                  hintText: '2026-04-01',
                ),
                onChanged: (v) => setState(() => startDateIso = v),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Total leave allocated'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => totalLeaveAllocated = v),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Salary amount monthly',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => salaryAmountMonthly = v),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Salary effective from (YYYY-MM-DD)',
                  hintText: '2026-04-01',
                ),
                onChanged: (v) => setState(() => salaryEffectiveFromIso = v),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Salary currency (optional, 3-letter)',
                  hintText: 'INR',
                ),
                onChanged: (v) => setState(() => salaryCurrency = v),
              ),
              const SizedBox(height: 12),
              if (submitError != null) ...[
                Text(submitError!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: (!isValid || isLoading) ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

