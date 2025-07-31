import 'package:agronexus/presentation/cubit/obscure_password/obscure_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onFieldSubmitted,
    this.label = _passwordLabel,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  static const String _passwordLabel = "Senha";
  static const String _passwordPlaceholder = "8+ caracteres";
  static const String _requiredField = "Campo obrigatório";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ObscurePasswordCubit(),
      child: BlocBuilder<ObscurePasswordCubit, ObscurePasswordState>(
        builder: (context, state) {
          return TextFormField(
            textInputAction: textInputAction,
            controller: controller,
            obscureText: state.obscureText,
            decoration: InputDecoration(
              label: Text(label),
              hintText: _passwordPlaceholder,
              suffixIcon: InkWell(
                onTap: context.read<ObscurePasswordCubit>().changeObscureText,
                child: Icon(
                  state.obscureText
                      ? FontAwesomeIcons.eyeSlash
                      : FontAwesomeIcons.eye,
                ),
              ),
            ),
            validator: (value) {
              if (value == null) return _requiredField;
              if (value.isEmpty) return _requiredField;
              if (validator != null) {
                final result = validator!(value);
                if (result != null) return result;
              }
              return null;
            },
            onFieldSubmitted: onFieldSubmitted,
            focusNode: focusNode,
          );
        },
      ),
    );
  }
}
