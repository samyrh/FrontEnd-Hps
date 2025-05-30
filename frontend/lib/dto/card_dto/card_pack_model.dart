class CardPackModel {
  final String label;
  final String audience;
  final double fee;
  final int validityYears;
  final double limitAnnual;
  final double limitDaily;
  final double limitMonthly;
  final bool internationalWithdraw;
  final int maxCountries;
  final int maxDays;
  final String type;

  CardPackModel({
    required this.label,
    required this.audience,
    required this.fee,
    required this.validityYears,
    required this.limitAnnual,
    required this.limitDaily,
    required this.limitMonthly,
    required this.internationalWithdraw,
    required this.maxCountries,
    required this.maxDays,
    required this.type,
  });

  factory CardPackModel.fromJson(Map<String, dynamic> json) {
    return CardPackModel(
      label: json['label'],
      audience: json['audience'],
      fee: (json['fee'] as num).toDouble(),
      validityYears: json['validityYears'],
      limitAnnual: (json['limitAnnual'] as num).toDouble(),
      limitDaily: (json['limitDaily'] as num).toDouble(),
      limitMonthly: (json['limitMonthly'] as num).toDouble(),
      internationalWithdraw: json['internationalWithdraw'] ?? false,
      maxCountries: json['maxCountries'],
      maxDays: json['maxDays'],
      type: json['type'],
    );
  }
}
