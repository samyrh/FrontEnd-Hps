class BlockVirtualCardRequest {
  final String blockReason;

  BlockVirtualCardRequest({required this.blockReason});

  Map<String, dynamic> toJson() => {
    'blockReason': blockReason,
  };
}
