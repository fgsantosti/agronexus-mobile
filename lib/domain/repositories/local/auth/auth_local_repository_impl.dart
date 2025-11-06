import 'package:agronexus/domain/repositories/local/auth/auth_local_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalRepositoryImpl implements AuthLocalRepository {
  static const _tokenKey = "token";
  static const _refreshTokenKey = "refresh";
  SharedPreferences? _sharedPreferences;

  AuthLocalRepositoryImpl() {
    _initSharedPreferences();
  }

  Future<void> _validateSharedInstance() async {
    if (_sharedPreferences == null) {
      await _initSharedPreferences();
    }
  }

  Future<void> _initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Future<void> deleteToken() async {
    await _validateSharedInstance();
    await _sharedPreferences!.remove(_tokenKey);
  }

  @override
  Future<void> deleteRefreshToken() async {
    await _validateSharedInstance();
    await _sharedPreferences!.remove(_refreshTokenKey);
  }

  @override
  Future<String> getToken() async {
    await _validateSharedInstance();
    return _sharedPreferences!.getString(_tokenKey) ?? "";
  }

  @override
  Future<String> getRefreshToken() async {
    await _validateSharedInstance();
    return _sharedPreferences!.getString(_refreshTokenKey) ?? "";
  }

  @override
  Future<void> saveToken(String token) async {
    await _validateSharedInstance();
    await _sharedPreferences!.setString(_tokenKey, token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _validateSharedInstance();
    await _sharedPreferences!.setString(_refreshTokenKey, token);
  }

  @override
  Future<void> logout() async {
    await _validateSharedInstance();

    // Remover apenas tokens de autenticação e dados do usuário
    // Preservar cache de dados (lotes, fazendas, animais, etc.) e preferências (showcase)
    final keysToRemove = [
      _tokenKey, // Token de acesso
      _refreshTokenKey, // Token de refresh
      'selfUser', // Dados do usuário logado
      'allUsers', // Lista de todos os usuários
    ];

    // Remover cada chave individualmente
    for (final key in keysToRemove) {
      await _sharedPreferences!.remove(key);
    }
  }
}
