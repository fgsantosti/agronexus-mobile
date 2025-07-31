import 'package:agronexus/config/routers/router.dart';
import 'package:agronexus/presentation/bloc/login/login_bloc.dart';
import 'package:agronexus/presentation/widgets/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _assetBanner = 'assets/logo.png';
  static const String _login = "Entrar";
  static const String _userLabel = "Usuário";
  static const String _userPlaceholder = "Digite seu usuário";
  static const String _requiredField = "Campo obrigatório";
  static const String _failOnLogin = "Falha ao realizar login";

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    context.read<LoginBloc>().add(AutoLoginEvent());
    super.initState();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
            PerformLoginEvent(
              email: _userController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state.status == LoginStatus.failure) {
            String errorMessage = state.errorMessage ?? _failOnLogin;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
          if (state.status == LoginStatus.success) {
            GoRouter router = GoRouter.of(context);
            router.pushReplacement(AgroNexusRouter.home.path);
          }
        },
        builder: (context, state) => Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                alignment: Alignment.center,
                child: Image.asset(_assetBanner, height: 150),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  top: 40,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      TextFormField(
                        controller: _userController,
                        decoration: InputDecoration(
                          label: Text(_userLabel),
                          hintText: _userPlaceholder,
                          prefixIcon: Icon(Icons.person),
                        ),
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        focusNode: _userFocusNode,
                        validator: (value) {
                          if (value == null) return _requiredField;
                          if (value.isEmpty) return _requiredField;
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          _userFocusNode.unfocus();
                          _passwordFocusNode.requestFocus();
                        },
                      ),
                      SizedBox(height: 24),
                      PasswordTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        onFieldSubmitted: (_) async {
                          _passwordFocusNode.unfocus();

                          await _performLogin();
                        },
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: state.status == LoginStatus.loading
                              ? null
                              : _performLogin,
                          child: Text(_login),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
