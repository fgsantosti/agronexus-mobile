import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/config/routers/router.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/presentation/bloc/user/user_bloc.dart';
import 'package:agronexus/presentation/widgets/password_text_field.dart';
import 'package:go_router/go_router.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  static const String _assetBanner = 'assets/logo.png';
  static const String _cadastrar = "Cadastrar";
  static const String _voltar = "Voltar ao Login";
  static const String _requiredField = "Campo obrigatório";
  static const String _invalidEmail = "E-mail inválido";
  static const String _passwordMismatch = "Senhas não conferem";
  static const String _minPasswordLength = "Senha deve ter pelo menos 8 caracteres";

  final _formKey = GlobalKey<FormState>();
  String? _passwordErrorFromApi; // Para armazenar erro da API
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Limpa o erro da API quando o usuário digita na senha
    _passwordController.addListener(() {
      if (_passwordErrorFromApi != null) {
        setState(() {
          _passwordErrorFromApi = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performCadastro() async {
    // Limpa erro anterior da API antes de tentar novamente
    setState(() {
      _passwordErrorFromApi = null;
    });

    if (_formKey.currentState!.validate()) {
      final userEntity = UserEntity(
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        cpf: '', // CPF não é obrigatório no endpoint
        password: _passwordController.text,
        password2: _confirmPasswordController.text,
      );

      context.read<UserBloc>().add(CreateUserEvent(
            user: userEntity,
            password: _passwordController.text,
            password2: _confirmPasswordController.text,
          ));
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return _requiredField;

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return _invalidEmail;

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return _requiredField;
    if (value.length < 8) return _minPasswordLength;

    // Se há erro da API relacionado à senha, mostra uma mensagem curta
    if (_passwordErrorFromApi != null && _passwordErrorFromApi!.isNotEmpty) {
      return "Verifique os requisitos da senha abaixo";
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return _requiredField;
    if (value != _passwordController.text) return _passwordMismatch;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) async {
          if (state.status == UserStatus.failure) {
            String errorMessage = state.errorMessage ?? 'Erro ao criar usuário';

            // Se o erro está relacionado à senha, mostra embaixo do campo
            if (errorMessage.toLowerCase().contains('senha')) {
              setState(() {
                _passwordErrorFromApi = errorMessage;
              });
              // Força a validação do campo de senha
              _formKey.currentState?.validate();
            } else {
              // Para outros erros, mostra no SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
          if (state.status == UserStatus.created) {
            // Limpa qualquer erro da API
            setState(() {
              _passwordErrorFromApi = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuário criado com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            // Aguarda um pouco antes de navegar para mostrar a mensagem
            await Future.delayed(const Duration(seconds: 1));
            if (context.mounted) {
              context.go(AgroNexusRouter.login.path); // Navega para a tela de login
            }
          }
        },
        builder: (context, state) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 32,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        child: Image.asset(_assetBanner, height: 120),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              'Criar uma conta',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Username field
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                label: Text('Nome de usuário'),
                                hintText: 'Digite seu nome de usuário',
                                prefixIcon: Icon(Icons.account_circle),
                              ),
                              autovalidateMode: AutovalidateMode.onUnfocus,
                              focusNode: _usernameFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) return _requiredField;
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _usernameFocusNode.unfocus();
                                _emailFocusNode.requestFocus();
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                label: Text('E-mail'),
                                hintText: 'Digite seu e-mail',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autovalidateMode: AutovalidateMode.onUnfocus,
                              focusNode: _emailFocusNode,
                              validator: _validateEmail,
                              onFieldSubmitted: (_) {
                                _emailFocusNode.unfocus();
                                _firstNameFocusNode.requestFocus();
                              },
                            ),
                            const SizedBox(height: 16),

                            // First name field
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                label: Text('Nome'),
                                hintText: 'Digite seu primeiro nome',
                                prefixIcon: Icon(Icons.person),
                              ),
                              autovalidateMode: AutovalidateMode.onUnfocus,
                              focusNode: _firstNameFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) return _requiredField;
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _firstNameFocusNode.unfocus();
                                _lastNameFocusNode.requestFocus();
                              },
                            ),
                            const SizedBox(height: 16),

                            // Last name field
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                label: Text('Sobrenome'),
                                hintText: 'Digite seu sobrenome',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              autovalidateMode: AutovalidateMode.onUnfocus,
                              focusNode: _lastNameFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) return _requiredField;
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _lastNameFocusNode.unfocus();
                                _passwordFocusNode.requestFocus();
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            PasswordTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              validator: _validatePassword,
                              onFieldSubmitted: (_) {
                                _passwordFocusNode.unfocus();
                                _confirmPasswordFocusNode.requestFocus();
                              },
                            ),

                            // Exibe a mensagem completa do erro da API
                            if (_passwordErrorFromApi != null && _passwordErrorFromApi!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border: Border.all(color: Colors.red.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _passwordErrorFromApi!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Confirm password field
                            PasswordTextField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              label: 'Confirmar Senha',
                              validator: _validateConfirmPassword,
                              onFieldSubmitted: (_) async {
                                _confirmPasswordFocusNode.unfocus();
                                await _performCadastro();
                              },
                            ),
                            const SizedBox(height: 24),

                            // Register button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.status == UserStatus.loading ? null : _performCadastro,
                                child: state.status == UserStatus.loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(_cadastrar),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Back to login button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: state.status == UserStatus.loading ? null : () => GoRouter.of(context).pop(),
                                child: const Text(_voltar),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
