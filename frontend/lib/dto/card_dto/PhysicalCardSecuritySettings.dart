class PhysicalCardSecuritySettings {
  final String label;
  final bool contactlessEnabled;
  final bool ecommerceEnabled;
  final bool tpeEnabled;
  final bool internationalWithdrawEnabled;
  final String username;
  final String cardholderName;

  PhysicalCardSecuritySettings({
    required this.label,
    required this.contactlessEnabled,
    required this.ecommerceEnabled,
    required this.tpeEnabled,
    required this.internationalWithdrawEnabled,
    required this.username,
    required this.cardholderName,
  });

  factory PhysicalCardSecuritySettings.fromJson(Map<String, dynamic> json) {
    return PhysicalCardSecuritySettings(
      label: json['label'] ?? "",
      contactlessEnabled: json['contactlessEnabled'] ?? false,
      ecommerceEnabled: json['ecommerceEnabled'] ?? false,
      tpeEnabled: json['tpeEnabled'] ?? false,
      internationalWithdrawEnabled: json['internationalWithdrawEnabled'] ?? false,
      username: json['username'] ?? "",
      cardholderName: json['cardholderName'] ?? "",
    );
  }
}
