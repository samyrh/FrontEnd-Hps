class UserInfoDto {
  final String username;
  final String email;

  UserInfoDto({
    required this.username,
    required this.email,
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(
      username: json['username'] ?? 'Unknown',
      email: json['email'] ?? 'Unknown',
    );
  }
}
