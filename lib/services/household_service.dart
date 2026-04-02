import '../api/api_client.dart';
import '../models/household.dart';

class HouseholdService {
  HouseholdService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<List<Household>> list() async {
    final resp = await _api.get<dynamic>('/households');
    final data = resp.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Household.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  Future<Household> create({
    required String name,
    required String type,
    required String currency,
  }) async {
    final resp = await _api.post<Map<String, dynamic>>(
      '/households',
      data: {'name': name, 'type': type, 'currency': currency},
    );
    final data = resp.data;
    if (data == null) throw StateError('Empty create household response');
    return Household.fromJson(data);
  }
}

