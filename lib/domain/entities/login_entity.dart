class LoginEntity {
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;
  final String? refreshToken;
  final String? userId;

  const LoginEntity({
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.refreshToken,
    this.userId,
  });
}
