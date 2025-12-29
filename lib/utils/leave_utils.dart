import '../models/leave_entry.dart';

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';
}

double countDaysForEntry(LeaveEntry entry) {
  double days = 0.0;
  DateTime current = entry.startDate;

  while (!current.isAfter(entry.endDate)) {
    days += entry.unitPerDay;
    current = current.add(const Duration(days: 1));
  }

  return days;
}