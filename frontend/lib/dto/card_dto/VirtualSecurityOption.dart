class VirtualSecurityOption {
  final String label;
  final bool ecommerceEnabled;
  final String username;
  final String cardholderName;

  VirtualSecurityOption({
    required this.label,
    required this.ecommerceEnabled,
    required this.username,
    required this.cardholderName,
  });

  factory VirtualSecurityOption.fromJson(Map<String, dynamic> json) {
    return VirtualSecurityOption(
      label: json['label'] ?? '',
      ecommerceEnabled: json['ecommerceEnabled'] ?? false,
      username: json['username'] ?? '',
      cardholderName: json['cardholderName'] ?? '',
    );
  }
}
