class SalaryRevision {
  const SalaryRevision({
    required this.id,
    required this.amountMonthly,
    required this.currency,
    required this.effectiveFrom,
    required this.isActive,
  });

  final String id;
  final int amountMonthly;
  final String currency;
  final DateTime effectiveFrom;
  final bool isActive;

  factory SalaryRevision.fromJson(Map<String, dynamic> json) {
    return SalaryRevision(
      id: json['id']?.toString() ?? '',
      amountMonthly: int.tryParse(json['amount_monthly']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? '',
      effectiveFrom: DateTime.tryParse(json['effective_from']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isActive: json['is_active'] == true,
    );
  }
}

