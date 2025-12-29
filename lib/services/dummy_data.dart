import '../models/staff.dart';
import '../models/leave_entry.dart';

final List<LeaveEntry> dummyLeaves = [
  LeaveEntry(
    id: 'l1',
    staffId: 's1',
    startDate: DateTime(2023, 12, 25),
    endDate: DateTime(2023, 12, 30),
    unitPerDay: 1.0,
    status: LeaveStatus.taken,
  ),
  LeaveEntry(
    id: 'l2',
    staffId: 's1',
    startDate: DateTime(2024, 1, 10),
    endDate: DateTime(2024, 1, 12),
    unitPerDay: 0.5,
    status: LeaveStatus.requested,
  ),
];

final List<Staff> dummyStaff = [
  Staff(
    id: 's1',
    householdId: '1',
    name: 'Ramesh Kumar',
    nickname: 'Ramu',
    role: 'Cook',
    startDate: DateTime(2022, 3, 1),
    totalLeaveAllocated: 18,
    agreedDuties: ['Cook', 'Clean', 'Wash'],
  ),
  Staff(
    id: 's2',
    householdId: '1',
    name: 'Sita Devi',
    nickname: null,
    role: 'Cleaner',
    startDate: DateTime(2021, 7, 15),
    totalLeaveAllocated: 12,
    agreedDuties: ['Clean', 'Wash', 'Iron'],
  ),
  Staff(
    id: 's3',
    householdId: '2',
    name: 'Amit Singh',
    nickname: null,
    role: 'Security',
    startDate: DateTime(2020, 1, 10),
    totalLeaveAllocated: 24,
    agreedDuties: ['Security', 'Clean', 'Wash'],
  ),
];