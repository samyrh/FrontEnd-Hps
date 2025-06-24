class CardRequestDTO {
  final String cardPackLabel;
  final String type;
  final String gradientStartColor;
  final String gradientEndColor;

  CardRequestDTO({
    required this.cardPackLabel,
    required this.type,
    required this.gradientStartColor,
    required this.gradientEndColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardPackLabel': cardPackLabel,
      'type': type,
      'gradientStartColor': gradientStartColor,
      'gradientEndColor': gradientEndColor,
    };
  }
}
