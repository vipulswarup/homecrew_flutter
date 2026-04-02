import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/household.dart';
import '../services/household_service.dart';

class HouseholdCreateScreen extends StatefulWidget {
  const HouseholdCreateScreen({super.key, required this.householdService});

  final HouseholdService householdService;

  @override
  State<HouseholdCreateScreen> createState() => _HouseholdCreateScreenState();
}

class _HouseholdCreateScreenState extends State<HouseholdCreateScreen> {
  String name = '';
  String type = '';
  String currency = '';
  bool isLoading = false;
  String? submitError;

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      submitError = null;
    });

    try {
      final household = await widget.householdService.create(
        name: name,
        type: type,
        currency: currency.toUpperCase(),
      );
      if (!mounted) return;
      Navigator.of(context).pop<Household>(household);
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
        type.trim().isNotEmpty &&
        currency.trim().length == 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Create household')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (v) => setState(() => name = v),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Type'),
              onChanged: (v) => setState(() => type = v),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Currency (3-letter code)',
                hintText: 'INR',
              ),
              onChanged: (v) => setState(() => currency = v),
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
    );
  }
}

