import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../models/salary_revision.dart';
import '../services/salary_service.dart';

class SalaryRevisionsScreen extends StatefulWidget {
  const SalaryRevisionsScreen({
    super.key,
    required this.salaryService,
    required this.staffId,
    required this.staffName,
  });

  final SalaryService salaryService;
  final String staffId;
  final String staffName;

  @override
  State<SalaryRevisionsScreen> createState() => _SalaryRevisionsScreenState();
}

class _SalaryRevisionsScreenState extends State<SalaryRevisionsScreen> {
  late Future<List<SalaryRevision>> _load = widget.salaryService.list(widget.staffId);
  String? submitError;

  Future<void> _reload() async {
    setState(() {
      _load = widget.salaryService.list(widget.staffId);
    });
  }

  Future<void> _addRevision() async {
    final amountController = TextEditingController();
    final currencyController = TextEditingController();
    final effectiveController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add salary revision'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount monthly'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: currencyController,
                decoration: const InputDecoration(labelText: 'Currency'),
              ),
              TextField(
                controller: effectiveController,
                decoration: const InputDecoration(
                  labelText: 'Effective from (YYYY-MM-DD)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final amount = int.tryParse(amountController.text.trim());
    final currency = currencyController.text.trim().toUpperCase();
    final effective = effectiveController.text.trim();
    if (amount == null || currency.isEmpty || effective.isEmpty) {
      setState(() {
        submitError = 'Invalid input';
      });
      return;
    }

    try {
      await widget.salaryService.create(
        staffId: widget.staffId,
        amountMonthly: amount,
        currency: currency,
        effectiveFromIso: effective,
      );
      await _reload();
    } catch (e) {
      final message = e is ApiException ? e.message : e.toString();
      setState(() {
        submitError = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.staffName} — Salary'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
          IconButton(icon: const Icon(Icons.add), onPressed: _addRevision),
        ],
      ),
      body: FutureBuilder<List<SalaryRevision>>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final err = snapshot.error;
            final message = err is ApiException ? err.message : '$err';
            return Center(child: Text(message, textAlign: TextAlign.center));
          }

          final rows = snapshot.data ?? const [];
          if (rows.isEmpty) {
            return Center(
              child: Text(
                submitError ?? 'No salary revisions yet.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: [
              if (submitError != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(submitError!, style: const TextStyle(color: Colors.red)),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final r = rows[index];
                    final date = r.effectiveFrom.toIso8601String().split('T').first;
                    return ListTile(
                      title: Text('${r.amountMonthly} ${r.currency}'),
                      subtitle: Text('Effective: $date'),
                      trailing: r.isActive ? const Text('Active') : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

