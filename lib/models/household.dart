class Household {
  final String id;
  final String name;
  final String type;
  final String? currency;

  Household({
    required this.id,
    required this.name,
    required this.type,
    this.currency,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      currency: json['currency']?.toString(),
    );
  }
}