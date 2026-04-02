import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/staff.dart';
import '../services/staff_service.dart';
import 'create_staff_screen.dart';
import 'staff_details_screen.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({
    super.key,
    required this.api,
    required this.householdId,
    required this.householdName,
  });

  final ApiClient api;
  final String householdId;
  final String householdName;

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  late final StaffService _staff = StaffService(api: widget.api);
  late Future<List<Staff>> _load = _staff.listForHousehold(widget.householdId);

  Future<void> _reload() async {
    setState(() {
      _load = _staff.listForHousehold(widget.householdId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.householdName),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.of(context).push<Staff>(
                MaterialPageRoute(
                  builder: (context) => CreateStaffScreen(
                    staffService: _staff,
                    householdId: widget.householdId,
                  ),
                ),
              );
              if (created != null) {
                await _reload();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Staff>>(
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

          final staffForHousehold = snapshot.data ?? const [];
          if (staffForHousehold.isEmpty) {
            return const Center(
              child: Text(
                'No staff members added yet.\nClick + to add your first staff member.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
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
                      builder: (context) => StaffDetailsScreen(
                        api: widget.api,
                        staffId: staff.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}