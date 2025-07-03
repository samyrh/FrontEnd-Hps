import 'TransactionResponseDTO.dart';

class TransactionGroupedResponse {
  final Map<int, List<TransactionResponseDTO>> transactionsByCardId;

  TransactionGroupedResponse({required this.transactionsByCardId});

  factory TransactionGroupedResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawMap = json['transactionsByCardId'];
    final Map<int, List<TransactionResponseDTO>> parsedMap = {};

    rawMap.forEach((key, value) {
      final int cardId = int.parse(key);
      final List<TransactionResponseDTO> transactions =
      (value as List).map((item) => TransactionResponseDTO.fromJson(item)).toList();
      parsedMap[cardId] = transactions;
    });

    return TransactionGroupedResponse(transactionsByCardId: parsedMap);
  }
}
