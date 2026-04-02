import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/household.dart';
import '../services/household_service.dart';
import 'household_create_screen.dart';
import 'staff_list_screen.dart';

class HouseholdListScreen extends StatefulWidget {
  const HouseholdListScreen({
    super.key,
    required this.api,
    this.appBarActions = const [],
  });

  final ApiClient api;
  final List<Widget> appBarActions;

  @override
  State<HouseholdListScreen> createState() => _HouseholdListScreenState();
}

class _HouseholdListScreenState extends State<HouseholdListScreen> {
  late final HouseholdService _households = HouseholdService(api: widget.api);
  late Future<List<Household>> _load = _households.list();

  Future<void> _reload() async {
    setState(() {
      _load = _households.list();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Households'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.of(context).push<Household>(
                MaterialPageRoute(
                  builder: (context) =>
                      HouseholdCreateScreen(householdService: _households),
                ),
              );
              if (created != null) {
                await _reload();
              }
            },
          ),
          ...widget.appBarActions,
        ],
      ),
      body: FutureBuilder<List<Household>>(
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

          final households = snapshot.data ?? const [];
          if (households.isEmpty) {
            return const Center(
              child: Text(
                'No households yet.\nClick + to create one.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: households.length,
            itemBuilder: (context, index) {
              final household = households[index];

              return ListTile(
                title: Text(household.name),
                subtitle: Text(
                  household.currency == null
                      ? household.type
                      : '${household.type} • ${household.currency}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StaffListScreen(
                        api: widget.api,
                        householdId: household.id,
                        householdName: household.name,
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