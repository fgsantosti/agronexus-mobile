import 'package:flutter/material.dart';
import 'package:agronexus/presentation/widgets/form_components.dart';

/// Mixin para proteger formulários contra múltiplos submits e cliques rápidos
///
/// Adiciona proteção contra:
/// - Cliques múltiplos muito rápidos (debounce)
/// - Submissões duplicadas
/// - Navegação duplicada
/// - Toques durante processamento
///
/// Uso:
/// ```dart
/// class _MeuFormScreenState extends State<MeuFormScreen> with FormSubmitProtectionMixin {
///   @override
///   Widget build(BuildContext context) {
///     return wrapWithProtection(
///       child: YourFormWidget(),
///     );
///   }
///
///   void _salvar() {
///     if (!canSubmit()) return;
///
///     markAsSubmitting();
///     // ... seu código de salvamento
///   }
/// }
/// ```
mixin FormSubmitProtectionMixin<T extends StatefulWidget> on State<T> {
  // Proteção contra cliques múltiplos e navegação duplicada
  bool _isSaving = false;
  bool _hasNavigated = false;
  DateTime? _lastClickTime;

  /// Duração mínima entre cliques (debounce)
  Duration get debounceDuration => const Duration(milliseconds: 500);

  /// Verifica se pode submeter o formulário
  /// Retorna false se:
  /// - Já estiver salvando
  /// - Já tiver navegado
  /// - Clique for muito rápido (debounce)
  bool canSubmit() {
    print('🔒 PROTECTION - Verificando se pode submeter...');
    print('🔒 PROTECTION - _isSaving: $_isSaving');
    print('🔒 PROTECTION - _hasNavigated: $_hasNavigated');

    // Prevenir múltiplos cliques (debounce)
    final now = DateTime.now();
    if (_lastClickTime != null && now.difference(_lastClickTime!) < debounceDuration) {
      final diff = now.difference(_lastClickTime!).inMilliseconds;
      print('⚠️ PROTECTION - Clique muito rápido, ignorando... (${diff}ms)');
      return false;
    }
    _lastClickTime = now;

    // Prevenir salvamento duplicado
    if (_isSaving || _hasNavigated) {
      print('⚠️ PROTECTION - Já está salvando ou já navegou, ignorando...');
      return false;
    }

    print('✅ PROTECTION - Pode submeter');
    return true;
  }

  /// Marca o formulário como "submetendo"
  void markAsSubmitting() {
    print('🔄 PROTECTION - Marcando como submetendo...');
    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }
  }

  /// Marca o formulário como "navegado"
  void markAsNavigated() {
    print('🔄 PROTECTION - Marcando como navegado...');
    if (mounted) {
      setState(() {
        _hasNavigated = true;
        _isSaving = false;
      });
    }
  }

  /// Reseta o estado de proteção (para permitir nova tentativa após erro)
  void resetProtection() {
    print('🔄 PROTECTION - Resetando proteção...');
    if (mounted) {
      setState(() {
        _isSaving = false;
        // Não resetar _hasNavigated para prevenir navegação duplicada
      });
    }
  }

  /// Reseta completamente o estado (útil para initState)
  void resetAllProtection() {
    print('🔄 PROTECTION - Reset completo...');
    _isSaving = false;
    _hasNavigated = false;
    _lastClickTime = null;
  }

  /// Verifica se está atualmente salvando
  bool get isSaving => _isSaving;

  /// Verifica se já navegou
  bool get hasNavigated => _hasNavigated;

  /// Envolve o widget filho com proteção visual
  /// - Desabilita toques quando está salvando
  /// - Reduz opacidade para feedback visual
  Widget wrapWithProtection({
    required Widget child,
    double opacity = 0.6,
  }) {
    return AbsorbPointer(
      absorbing: _isSaving || _hasNavigated,
      child: Opacity(
        opacity: _isSaving || _hasNavigated ? opacity : 1.0,
        child: child,
      ),
    );
  }

  /// Navega de volta com proteção
  /// - Verifica se o widget ainda está montado
  /// - Verifica se não há navegação em andamento
  /// - Marca como navegado para prevenir duplicação
  Future<void> safeNavigateBack<R>({
    R? result,
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    print('🚪 PROTECTION - Tentando navegar de volta...');
    print('🚪 PROTECTION - mounted: $mounted');
    print('🚪 PROTECTION - _hasNavigated: $_hasNavigated');

    // Prevenir navegação duplicada
    if (_hasNavigated) {
      print('⚠️ PROTECTION - Navegação já realizada, ignorando...');
      return;
    }

    // Marcar como navegado
    markAsNavigated();

    // Aguardar delay (útil para mostrar SnackBar antes de navegar)
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    print('🚪 PROTECTION - Verificando condições de navegação...');
    if (mounted && !Navigator.of(context).userGestureInProgress) {
      print('✅ PROTECTION - Navegando de volta');
      Navigator.of(context).pop(result);
    } else {
      print('⚠️ PROTECTION - Não foi possível navegar: mounted=$mounted');
    }
  }

  /// Mostra SnackBar com proteção usando componentes padronizados
  void showProtectedSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      if (isError) {
        FormSnackBar.showError(context, message);
      } else {
        FormSnackBar.showSuccess(context, message);
      }
    }
  }
}
