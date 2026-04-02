class Staff {
  final String id;
  final String name;
  final String role;
  final String householdId;

  final String? nickname;
  final DateTime startDate;
  final int totalLeaveAllocated;
  final List<String> agreedDuties;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.householdId,
    this.nickname,
    required this.startDate,
    required this.totalLeaveAllocated,
    required this.agreedDuties,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.tryParse(v.toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    final duties = json['agreed_duties'];
    final List<String> agreed = duties is List
        ? duties.map((e) => e.toString()).toList()
        : const [];

    return Staff(
      id: json['id']?.toString() ?? '',
      householdId: json['household_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nickname: json['nickname']?.toString(),
      role: json['role']?.toString() ?? '',
      startDate: parseDate(json['start_date']),
      totalLeaveAllocated:
          int.tryParse(json['total_leave_allocated']?.toString() ?? '') ?? 0,
      agreedDuties: agreed,
    );
  }

  Staff copyWith({
    String? nickname,
    String? role,
    DateTime? startDate,
    int? totalLeaveAllocated,
    List<String>? agreedDuties,
  }) {
    return Staff(
      id: id,
      householdId: householdId,
      name: name,
      role: role ?? this.role,
      nickname: nickname,
      startDate: startDate ?? this.startDate,
      totalLeaveAllocated: totalLeaveAllocated ?? this.totalLeaveAllocated,
      agreedDuties: agreedDuties ?? this.agreedDuties,
    );
  }
}