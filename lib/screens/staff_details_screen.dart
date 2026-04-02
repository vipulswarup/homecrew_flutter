import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/staff.dart';
import '../services/salary_service.dart';
import '../services/staff_service.dart';
import 'edit_staff_screen.dart';
import 'salary_revisions_screen.dart';
import 'staff_documents_screen.dart';
import '../services/document_service.dart';
import '../models/staff_document.dart';

class StaffDetailsScreen extends StatefulWidget {
  const StaffDetailsScreen({super.key, required this.api, required this.staffId});

  final ApiClient api;
  final String staffId;

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  late final StaffService _staffService = StaffService(api: widget.api);
  late final SalaryService _salaryService = SalaryService(api: widget.api);
  late final DocumentService _documentService = DocumentService(api: widget.api);
  late Future<Staff> _load = _staffService.getById(widget.staffId);
  late Future<List<StaffDocument>> _docsLoad =
      _documentService.listForStaff(staffId: widget.staffId);

  Future<void> _reload() async {
    setState(() {
      _load = _staffService.getById(widget.staffId);
      _docsLoad = _documentService.listForStaff(staffId: widget.staffId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final current = await _load;
              if (!context.mounted) return;
              final updatedStaff = await Navigator.of(context).push<Staff>(
                MaterialPageRoute(
                  builder: (context) => EditStaffScreen(staff: current),
                ),
              );

              if (updatedStaff != null) {
                await _staffService.update(
                  staffId: updatedStaff.id,
                  nickname: updatedStaff.nickname,
                  role: updatedStaff.role,
                  startDateIso:
                      updatedStaff.startDate.toIso8601String().split('T').first,
                  totalLeaveAllocated: updatedStaff.totalLeaveAllocated,
                  agreedDuties: updatedStaff.agreedDuties,
                );
                await _reload();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Staff>(
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

          final staff = snapshot.data;
          if (staff == null) {
            return const Center(child: Text('Staff not found'));
          }

          final joined = staff.startDate.toIso8601String().split('T').first;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                Text(
                  staff.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (staff.nickname != null && staff.nickname!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Nickname: ${staff.nickname}'),
                ],
                const SizedBox(height: 8),
                Text(staff.role, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Text('Joined on: $joined'),
                const SizedBox(height: 8),
                Text('Total Leave Allocated: ${staff.totalLeaveAllocated} days'),
                const SizedBox(height: 24),
                const Text(
                  'Agreed Duties',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (staff.agreedDuties.isEmpty)
                  const Text('None')
                else
                  for (final duty in staff.agreedDuties) Text('• $duty'),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SalaryRevisionsScreen(
                          salaryService: _salaryService,
                          staffId: staff.id,
                          staffName: staff.name,
                        ),
                      ),
                    );
                  },
                  child: const Text('View salary revisions'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Documents',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<StaffDocument>>(
                  future: _docsLoad,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Failed to load documents: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    final docs = snapshot.data ?? const [];
                    if (docs.isEmpty) {
                      return const Text('No documents uploaded yet.');
                    }

                    final preview = docs.take(3).toList();
                    return Column(
                      children: [
                        for (final d in preview)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(d.fileName),
                            subtitle: Text(d.fileType),
                            trailing: IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete document?'),
                                      content: Text(d.fileName),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (ok == true) {
                                  await _documentService.delete(
                                    documentId: d.id,
                                  );
                                  await _reload();
                                }
                              },
                            ),
                          ),
                        if (docs.length > 3)
                          Text('And ${docs.length - 3} more...'),
                      ],
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StaffDocumentsScreen(
                          documentService: _documentService,
                          householdId: staff.householdId,
                          staffId: staff.id,
                          staffName: staff.name,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open documents'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}