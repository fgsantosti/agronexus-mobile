import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'obscure_password_state.dart';

class ObscurePasswordCubit extends Cubit<ObscurePasswordState> {
  ObscurePasswordCubit() : super(const ObscurePasswordState(obscureText: true));

  void changeObscureText() {
    emit(ObscurePasswordState(obscureText: !state.obscureText));
  }
}
