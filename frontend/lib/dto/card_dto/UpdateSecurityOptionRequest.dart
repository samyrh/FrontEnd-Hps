class UpdateSecurityOptionRequest {
  final int cardId;
  final bool? contactlessEnabled;
  final bool? ecommerceEnabled;
  final bool? tpeEnabled;

  UpdateSecurityOptionRequest({
    required this.cardId,
    this.contactlessEnabled,
    this.ecommerceEnabled,
    this.tpeEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      if (contactlessEnabled != null) 'contactlessEnabled': contactlessEnabled,
      if (ecommerceEnabled != null) 'ecommerceEnabled': ecommerceEnabled,
      if (tpeEnabled != null) 'tpeEnabled': tpeEnabled,
    };
  }
}
