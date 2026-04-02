import '../api/api_client.dart';
import '../models/staff.dart';

class StaffService {
  StaffService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<List<Staff>> listForHousehold(String householdId) async {
    final resp = await _api.get<dynamic>('/households/$householdId/staff');
    final data = resp.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Staff.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  Future<Staff> getById(String staffId) async {
    final resp = await _api.get<Map<String, dynamic>>('/staff/$staffId');
    final data = resp.data;
    if (data == null) throw StateError('Empty staff response');
    return Staff.fromJson(data);
  }

  Future<Staff> create({
    required String householdId,
    required String name,
    required String nickname,
    required String role,
    required String startDateIso,
    required int totalLeaveAllocated,
    required int salaryAmountMonthly,
    required String salaryEffectiveFromIso,
    String? salaryCurrency,
  }) async {
    final resp = await _api.post<Map<String, dynamic>>(
      '/households/$householdId/staff',
      data: {
        'name': name,
        'nickname': nickname,
        'role': role,
        'start_date': startDateIso,
        'total_leave_allocated': totalLeaveAllocated,
        'salary_amount_monthly': salaryAmountMonthly,
        'salary_effective_from': salaryEffectiveFromIso,
        if (salaryCurrency != null && salaryCurrency.trim().isNotEmpty)
          'salary_currency': salaryCurrency,
      },
    );
    final data = resp.data;
    if (data == null) throw StateError('Empty create staff response');
    return Staff.fromJson(data);
  }

  Future<Staff> update({
    required String staffId,
    String? nickname,
    String? role,
    String? startDateIso,
    int? totalLeaveAllocated,
    List<String>? agreedDuties,
  }) async {
    final resp = await _api.patch<Map<String, dynamic>>(
      '/staff/$staffId',
      data: {
        'nickname': nickname,
        'role': role,
        'start_date': startDateIso,
        'total_leave_allocated': totalLeaveAllocated,
        'agreed_duties': agreedDuties,
      },
    );
    final data = resp.data;
    if (data == null) throw StateError('Empty update staff response');
    return Staff.fromJson(data);
  }

  Future<void> delete(String staffId) async {
    await _api.delete<void>('/staff/$staffId');
  }
}

