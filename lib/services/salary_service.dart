import '../api/api_client.dart';
import '../models/salary_revision.dart';

class SalaryService {
  SalaryService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<List<SalaryRevision>> list(String staffId) async {
    final resp = await _api.get<dynamic>('/staff/$staffId/salary-revisions');
    final data = resp.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => SalaryRevision.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  Future<void> create({
    required String staffId,
    required int amountMonthly,
    required String currency,
    required String effectiveFromIso,
  }) async {
    await _api.post<void>(
      '/staff/$staffId/salary-revisions',
      data: {
        'amount_monthly': amountMonthly,
        'currency': currency,
        'effective_from': effectiveFromIso,
      },
    );
  }
}

