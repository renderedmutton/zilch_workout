class AuthCredentials {
  final String username;
  final String? nickname;
  final String? password;
  String? userId;

  AuthCredentials({
    required this.username,
    this.nickname,
    this.password,
    this.userId,
  });
}
