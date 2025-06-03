import 'card_pack_model.dart';

class CardModel {

  final int id;
  final String cardNumber;
  final String type;
  final String status;
  final String? blockReason;
  final String expirationDate;
  final bool contactlessEnabled;
  final bool ecommerceEnabled;
  final bool tpeEnabled;
  final double dailyLimit;
  final double monthlyLimit;
  final double annualLimit;
  final bool internationalWithdraw;
  final String? blockEndDate;
  final bool isCanceled;
  final CardPackModel cardPack;
  final String gradientStartColor;
  final String gradientEndColor;
  final double balance;
  final String cardholderName;

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
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.annualLimit,
    required this.internationalWithdraw,
    required this.blockEndDate,
    required this.isCanceled,
    required this.cardPack,
    required this.gradientStartColor,
    required this.gradientEndColor,
    required this.balance,
    required this.cardholderName,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      cardNumber: json['cardNumber'],
      type: json['type'],
      status: json['status'],
      blockReason: json['blockReason'],
      expirationDate: json['expirationDate'],
      contactlessEnabled: json['contactlessEnabled'] ?? false,
      ecommerceEnabled: json['ecommerceEnabled'] ?? false,
      tpeEnabled: json['tpeEnabled'] ?? false,
      dailyLimit: (json['dailyLimit'] as num).toDouble(),
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
      annualLimit: (json['annualLimit'] as num).toDouble(),
      internationalWithdraw: json['internationalWithdraw'] ?? false,
      blockEndDate: json['blockEndDate'],
      isCanceled: json['isCanceled'] ?? false,
      cardPack: CardPackModel.fromJson(json['cardPack']),
      gradientStartColor: json['gradientStartColor'] ?? '#000000',
      gradientEndColor: json['gradientEndColor'] ?? '#000000',
      balance: (json['balance'] as num).toDouble(),
      cardholderName: json['cardholderName'] ?? 'Cardholder',
    );
  }
}
