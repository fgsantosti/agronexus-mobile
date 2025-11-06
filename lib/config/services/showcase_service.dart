import 'package:shared_preferences/shared_preferences.dart';

class ShowcaseService {
  static const String _homeShowcaseKey = 'home_showcase_completed';
  static const String _propriedadeShowcaseKey = 'propriedade_showcase_completed';

  /// Verifica se o showcase da home já foi exibido
  Future<bool> isHomeShowcaseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_homeShowcaseKey) ?? false;
  }

  /// Marca o showcase da home como completo
  Future<void> setHomeShowcaseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeShowcaseKey, true);
  }

  /// Verifica se o showcase de propriedades já foi exibido
  Future<bool> isPropriedadeShowcaseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_propriedadeShowcaseKey) ?? false;
  }

  /// Marca o showcase de propriedades como completo
  Future<void> setPropriedadeShowcaseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_propriedadeShowcaseKey, true);
  }

  /// Reseta todos os showcases (útil para testes)
  Future<void> resetAllShowcases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeShowcaseKey);
    await prefs.remove(_propriedadeShowcaseKey);
  }
}
