
class ReplaceVirtualCardRequest {
  final int blockedCardId;

  ReplaceVirtualCardRequest({required this.blockedCardId});

  Map<String, dynamic> toJson() => {
    'blockedCardId': blockedCardId,
  };
}
