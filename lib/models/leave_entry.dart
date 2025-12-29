class LeaveEntry {
  final String id;
  final String staffId;
  final DateTime startDate;
  final DateTime endDate;
  final double unitPerDay; // 1.0 or 0.5
  final LeaveStatus status;

  LeaveEntry({
    required this.id,
    required this.staffId,
    required this.startDate,
    required this.endDate,
    required this.unitPerDay,
    required this.status,
  });
}

enum LeaveStatus { requested, taken }