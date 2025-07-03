class TransactionResponseDTO {
  final int id;
  final DateTime date;
  final String merchant;
  final double amount;
  final String category;
  final String description;
  final String status;
  final int cardId;
  final String cardNumberMasked;

  TransactionResponseDTO({
    required this.id,
    required this.date,
    required this.merchant,
    required this.amount,
    required this.category,
    required this.description,
    required this.status,
    required this.cardId,
    required this.cardNumberMasked,
  });

  factory TransactionResponseDTO.fromJson(Map<String, dynamic> json) {
    return TransactionResponseDTO(
      id: json['id'],
      date: DateTime.parse(json['date']),
      merchant: json['merchant'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      description: json['description'],
      status: json['status'],
      cardId: json['cardId'],
      cardNumberMasked: json['cardNumberMasked'] ?? '****', // ✅ Added parsing with fallback
    );
  }
}
