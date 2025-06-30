class PhysicalCardSecurityOption {
  final int cardId;
  final String label;
  final bool contactlessEnabled;
  final bool ecommerceEnabled;
  final bool tpeEnabled;
  final bool internationalWithdrawEnabled;
  final String username;
  final String cardholderName;

  PhysicalCardSecurityOption({
    required this.cardId,
    required this.label,
    required this.contactlessEnabled,
    required this.ecommerceEnabled,
    required this.tpeEnabled,
    required this.internationalWithdrawEnabled,
    required this.username,
    required this.cardholderName,
  });

  factory PhysicalCardSecurityOption.fromJson(Map<String, dynamic> json) {
    return PhysicalCardSecurityOption(
      cardId: json['cardId'],
      label: json['label'],
      contactlessEnabled: json['contactlessEnabled'],
      ecommerceEnabled: json['ecommerceEnabled'],
      tpeEnabled: json['tpeEnabled'],
      internationalWithdrawEnabled: json['internationalWithdrawEnabled'],
      username: json['username'],
      cardholderName: json['cardholderName'],
    );
  }
}
