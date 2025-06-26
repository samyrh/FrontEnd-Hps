class UpdatePhysicalCardLimitsRequest {
  final double newDailyLimit;
  final double newMonthlyLimit;
  final double newAnnualLimit;

  UpdatePhysicalCardLimitsRequest({
    required this.newDailyLimit,
    required this.newMonthlyLimit,
    required this.newAnnualLimit,
  });

  Map<String, dynamic> toJson() => {
    "newDailyLimit": newDailyLimit,
    "newMonthlyLimit": newMonthlyLimit,
    "newAnnualLimit": newAnnualLimit,
  };
}
