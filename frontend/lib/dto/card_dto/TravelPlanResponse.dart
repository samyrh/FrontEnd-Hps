class TravelPlanResponse {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> countries;
  final String status;
  final double travelLimit;
  final int maxDays;

  TravelPlanResponse({
    required this.startDate,
    required this.endDate,
    required this.countries,
    required this.status,
    required this.travelLimit,
    required this.maxDays,
  });

  factory TravelPlanResponse.fromJson(Map<String, dynamic> json) {
    return TravelPlanResponse(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      countries: List<String>.from(json['countries']),
      status: json['status'],
      travelLimit: json['travelLimit']?.toDouble() ?? 0.0,
      maxDays: json['maxDays'] ?? 0,
    );
  }
}
