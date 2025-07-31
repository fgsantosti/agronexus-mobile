abstract class AuthLocalRepository {
  Future<void> saveToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<void> deleteToken();
  Future<void> deleteRefreshToken();
  Future<String> getToken();
  Future<String> getRefreshToken();
  Future<void> logout();
}
