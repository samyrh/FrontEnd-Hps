class LoginUserDto {
  final String username;
  final String password;

  LoginUserDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}
