part of 'obscure_password_cubit.dart';

class ObscurePasswordState extends Equatable {
  final bool obscureText;

  const ObscurePasswordState({required this.obscureText});

  @override
  List<Object> get props => [obscureText];
}
