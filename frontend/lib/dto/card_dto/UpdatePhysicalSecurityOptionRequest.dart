class UpdatePhysicalSecurityOptionRequest {
  final int cardId;
  final bool? contactlessEnabled;
  final bool? ecommerceEnabled;
  final bool? tpeEnabled;
  final bool? internationalWithdrawEnabled;

  UpdatePhysicalSecurityOptionRequest({
    required this.cardId,
    this.contactlessEnabled,
    this.ecommerceEnabled,
    this.tpeEnabled,
    this.internationalWithdrawEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      "cardId": cardId,
      if (contactlessEnabled != null) "contactlessEnabled": contactlessEnabled,
      if (ecommerceEnabled != null) "ecommerceEnabled": ecommerceEnabled,
      if (tpeEnabled != null) "tpeEnabled": tpeEnabled,
      if (internationalWithdrawEnabled != null) "internationalWithdrawEnabled": internationalWithdrawEnabled,
    };
  }
}
