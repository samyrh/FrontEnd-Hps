class NotificationPreferencesDTO {
  bool cardStatusNotification;
  bool cardCancelNotification;
  bool newCardRequestNotification;
  bool cardReplacementNotification;
  bool travelPlanNotification;
  bool transactionNotification;

  NotificationPreferencesDTO({
    required this.cardStatusNotification,
    required this.cardCancelNotification,
    required this.newCardRequestNotification,
    required this.cardReplacementNotification,
    required this.travelPlanNotification,
    required this.transactionNotification,
  });

  factory NotificationPreferencesDTO.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDTO(
      cardStatusNotification: json['cardStatusNotification'] ?? false,
      cardCancelNotification: json['cardCancelNotification'] ?? false,
      newCardRequestNotification: json['newCardRequestNotification'] ?? false,
      cardReplacementNotification: json['cardReplacementNotification'] ?? false,
      travelPlanNotification: json['travelPlanNotification'] ?? false,
      transactionNotification: json['transactionNotification'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardStatusNotification': cardStatusNotification,
      'cardCancelNotification': cardCancelNotification,
      'newCardRequestNotification': newCardRequestNotification,
      'cardReplacementNotification': cardReplacementNotification,
      'travelPlanNotification': travelPlanNotification,
      'transactionNotification': transactionNotification,
    };
  }
}
