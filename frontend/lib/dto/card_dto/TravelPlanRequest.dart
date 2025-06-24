class TravelPlanRequest {
  final List<String> countries;
  final DateTime startDate;
  final DateTime endDate;

  TravelPlanRequest({
    required this.countries,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'countries': countries,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };
}
