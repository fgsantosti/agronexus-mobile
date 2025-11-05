import 'package:flutter/material.dart';

/// Componentes padronizados para formulários do AgroNexus
///
/// Fornece widgets consistentes para:
/// - AppBar com botão salvar
/// - Botões de ação
/// - SnackBars
/// - Layout de formulários

// ============================================================================
// CORES PADRÃO
// ============================================================================

class FormColors {
  static const Color primary = Color(0xFF4CAF50); // Verde padrão
  static const Color success = Color(0xFF4CAF50); // Verde sucesso
  static const Color error = Color(0xFFF44336); // Vermelho erro
  static const Color white = Colors.white;
  static const Color disabled = Color(0xFFBDBDBD); // Cinza desabilitado
}

// ============================================================================
// APPBAR PADRONIZADO PARA FORMULÁRIOS
// ============================================================================

/// AppBar padronizado para formulários com botão salvar
///
/// Uso:
/// ```dart
/// FormAppBar(
///   title: 'Cadastrar Animal',
///   onSave: _salvar,
///   isSaving: _isSaving,
/// )
/// ```
class FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool showSaveButton;
  final String? saveButtonText;
  final List<Widget>? additionalActions;

  const FormAppBar({
    super.key,
    required this.title,
    this.onSave,
    this.isSaving = false,
    this.showSaveButton = true,
    this.saveButtonText,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: FormColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: FormColors.primary,
      foregroundColor: FormColors.white,
      elevation: 2,
      centerTitle: false,
      iconTheme: const IconThemeData(color: FormColors.white),
      actions: [
        if (additionalActions != null) ...additionalActions!,
        if (showSaveButton)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: isSaving ? null : onSave,
              style: TextButton.styleFrom(
                foregroundColor: FormColors.white,
                disabledForegroundColor: FormColors.white.withOpacity(0.5),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(FormColors.white),
                      ),
                    )
                  : Text(
                      saveButtonText ?? 'Salvar',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ============================================================================
// BOTÃO PRIMÁRIO PADRONIZADO
// ============================================================================

/// Botão primário verde padronizado para formulários
///
/// Uso:
/// ```dart
/// FormPrimaryButton(
///   text: 'Salvar',
///   onPressed: _salvar,
///   isLoading: _isSaving,
/// )
/// ```
class FormPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;
  final EdgeInsetsGeometry? padding;

  const FormPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: FormColors.primary,
        foregroundColor: FormColors.white,
        disabledBackgroundColor: FormColors.disabled,
        disabledForegroundColor: FormColors.white.withOpacity(0.5),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(FormColors.white),
              ),
            )
          : icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

// ============================================================================
// BOTÃO SECUNDÁRIO PADRONIZADO
// ============================================================================

/// Botão secundário (outline) padronizado para formulários
///
/// Uso:
/// ```dart
/// FormSecondaryButton(
///   text: 'Cancelar',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class FormSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final EdgeInsetsGeometry? padding;

  const FormSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: FormColors.primary,
        side: const BorderSide(color: FormColors.primary, width: 2),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

// ============================================================================
// SNACKBAR HELPERS PADRONIZADOS
// ============================================================================

/// Helpers para mostrar SnackBars padronizados
class FormSnackBar {
  /// Mostra SnackBar de sucesso (fundo verde)
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: FormColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: FormColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: FormColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Mostra SnackBar de erro (fundo vermelho)
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: FormColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: FormColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: FormColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Mostra SnackBar de informação (fundo azul)
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: FormColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: FormColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ============================================================================
// CONTAINER PADRONIZADO PARA FORMULÁRIOS
// ============================================================================

/// Container padronizado para seções de formulário
///
/// Uso:
/// ```dart
/// FormSection(
///   title: 'Informações Básicas',
///   children: [
///     TextField(...),
///     TextField(...),
///   ],
/// )
/// ```
class FormSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const FormSection({
    super.key,
    this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: FormColors.primary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            )),
      ],
    );
  }
}

// ============================================================================
// WIDGET BASE PARA FORMULÁRIOS COM SCROLL
// ============================================================================

/// Widget base para formulários com scroll automático
///
/// Uso:
/// ```dart
/// FormScrollView(
///   padding: EdgeInsets.all(16),
///   children: [
///     FormSection(...),
///     FormPrimaryButton(...),
///   ],
/// )
/// ```
class FormScrollView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const FormScrollView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics,
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// ============================================================================
// BOTÕES DE NAVEGAÇÃO DE STEPS
// ============================================================================

/// Botões de navegação para formulários com múltiplos steps
///
/// Uso:
/// ```dart
/// FormStepButtons(
///   currentStep: 0,
///   totalSteps: 3,
///   onNext: _proximoPasso,
///   onPrevious: _passoAnterior,
///   onSave: _salvar,
///   isSaving: _isSaving,
/// )
/// ```
class FormStepButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool showBackOnLastStep;

  const FormStepButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onNext,
    this.onPrevious,
    this.onSave,
    this.isSaving = false,
    this.showBackOnLastStep = false,
  });

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    // Se for o último step e showBackOnLastStep for false, mostrar apenas o botão salvar
    if (isLastStep && !showBackOnLastStep) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: FormPrimaryButton(
          text: 'Salvar',
          icon: Icons.check,
          onPressed: onSave,
          isLoading: isSaving,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão Voltar
          if (!isFirstStep)
            Expanded(
              child: FormSecondaryButton(
                text: 'Voltar',
                icon: Icons.arrow_back,
                onPressed: onPrevious,
              ),
            ),

          if (!isFirstStep) const SizedBox(width: 16),

          // Botão Próximo/Salvar
          Expanded(
            child: FormPrimaryButton(
              text: isLastStep ? 'Salvar' : 'Próximo',
              icon: isLastStep ? Icons.check : Icons.arrow_forward,
              onPressed: isLastStep ? onSave : onNext,
              isLoading: isSaving && isLastStep,
            ),
          ),
        ],
      ),
    );
  }
}
