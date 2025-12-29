class Staff {
  final String id;
  final String householdId;
  final String name;
  final String role;

  final String? nickname;
  final DateTime startDate;
  final int totalLeaveAllocated;
  final List<String> agreedDuties;

  Staff({
    required this.id,
    required this.householdId,
    required this.name,
    required this.role,
    this.nickname,
    required this.startDate,
    required this.totalLeaveAllocated,
    required this.agreedDuties,
  });

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