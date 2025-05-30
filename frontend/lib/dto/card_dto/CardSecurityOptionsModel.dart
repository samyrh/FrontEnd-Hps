class CardSecurityOptionsModel {
  final String label;
  final bool contactlessEnabled;
  final bool ecommerceEnabled;
  final bool tpeEnabled;
  final String username;
  final String cardholderName;

  CardSecurityOptionsModel({
    required this.label,
    required this.contactlessEnabled,
    required this.ecommerceEnabled,
    required this.tpeEnabled,
    required this.username,
    required this.cardholderName,
  });

  factory CardSecurityOptionsModel.fromJson(Map<String, dynamic> json) {
    return CardSecurityOptionsModel(
      label: json['label'],
      contactlessEnabled: json['contactlessEnabled'] ?? false,
      ecommerceEnabled: json['ecommerceEnabled'] ?? false,
      tpeEnabled: json['tpeEnabled'] ?? false,
      username: json['username'],
      cardholderName: json['cardholderName'],
    );
  }
}
