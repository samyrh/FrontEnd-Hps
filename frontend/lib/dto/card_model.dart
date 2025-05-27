import 'card_pack_model.dart';

class CardModel {
  final int id;
  final String cardNumber;
  final String type; // e.g. "PHYSICAL" / "VIRTUAL"
  final String status; // e.g. "ACTIVE"
  final String? blockReason;
  final String expirationDate;
  final bool contactlessEnabled;
  final bool ecommerceEnabled;
  final bool tpeEnabled;
  final double spendingLimit;
  final String limitType;
  final String? blockEndDate;
  final bool isCanceled;
  final CardPackModel cardPack;

  CardModel({
    required this.id,
    required this.cardNumber,
    required this.type,
    required this.status,
    required this.blockReason,
    required this.expirationDate,
    required this.contactlessEnabled,
    required this.ecommerceEnabled,
    required this.tpeEnabled,
    required this.spendingLimit,
    required this.limitType,
    required this.blockEndDate,
    required this.isCanceled,
    required this.cardPack,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      cardNumber: json['cardNumber'],
      type: json['type'],
      status: json['status'],
      blockReason: json['blockReason'],
      expirationDate: json['expirationDate'],
      contactlessEnabled: json['contactlessEnabled'],
      ecommerceEnabled: json['ecommerceEnabled'],
      tpeEnabled: json['tpeEnabled'],
      spendingLimit: (json['spendingLimit'] as num).toDouble(),
      limitType: json['limitType'],
      blockEndDate: json['blockEndDate'],
      isCanceled: json['isCanceled'],
      cardPack: CardPackModel.fromJson(json['cardPack']),
    );
  }
}
