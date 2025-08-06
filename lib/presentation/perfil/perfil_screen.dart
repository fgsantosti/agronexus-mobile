import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/presentation/bloc/user/user_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  UserEntity? _cachedUser;
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    context.read<UserBloc>().add(const GetSelfUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: () async => _loadUserData(),
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state.status == UserStatus.success && state.entity != null) {
            _cachedUser = state.entity;
          }
          
          if (state.status == UserStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Erro ao carregar dados do usuário'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state.status == UserStatus.loading && _cachedUser == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = _cachedUser ?? state.entity;
              
              if (user == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.userXmark,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Não foi possível carregar os dados do usuário',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header com avatar
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primaryContainer,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              FontAwesomeIcons.user,
                              size: 60,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.firstName.isNotEmpty ? user.firstName : 'Usuário',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.isActive == true 
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: user.isActive == true 
                                  ? Colors.green 
                                  : Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.isActive == true ? 'Ativo' : 'Inativo',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: user.isActive == true 
                                  ? Colors.green.shade700 
                                  : Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Seção de Informações Pessoais
                    Text(
                      'Informações Pessoais',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoItem(
                          context,
                          icon: FontAwesomeIcons.user,
                          label: 'Nome',
                          value: user.firstName.isNotEmpty ? user.firstName : 'Não informado',
                        ),
                        const Divider(),
                        _buildInfoItem(
                          context,
                          icon: FontAwesomeIcons.envelope,
                          label: 'Email',
                          value: user.email.isNotEmpty ? user.email : 'Não informado',
                        ),
                        const Divider(),
                        _buildInfoItem(
                          context,
                          icon: FontAwesomeIcons.idCard,
                          label: 'CPF',
                          value: user.cpf.isNotEmpty 
                            ? _cpfFormatter.maskText(user.cpf)
                            : 'Não informado',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Seção de Configurações da Conta
                    Text(
                      'Configurações da Conta',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoItem(
                          context,
                          icon: FontAwesomeIcons.userShield,
                          label: 'Tipo de Usuário',
                          value: user.isStaff == true ? 'Administrador' : 'Usuário Padrão',
                        ),
                        const Divider(),
                        _buildInfoItem(
                          context,
                          icon: FontAwesomeIcons.calendar,
                          label: 'Data de Cadastro',
                          value: user.createdAt != null 
                            ? _formatDate(user.createdAt!)
                            : 'Não informado',
                        ),
                        if (user.modifiedAt != null && user.modifiedAt != user.createdAt) ...[
                          const Divider(),
                          _buildInfoItem(
                            context,
                            icon: FontAwesomeIcons.clock,
                            label: 'Última Atualização',
                            value: _formatDate(user.modifiedAt!),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botões de Ação
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implementar edição de perfil
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcionalidade de edição será implementada em breve'),
                                ),
                              );
                            },
                            icon: const Icon(FontAwesomeIcons.userPen),
                            label: const Text('Editar Perfil'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implementar mudança de senha
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcionalidade de mudança de senha será implementada em breve'),
                                ),
                              );
                            },
                            icon: const Icon(FontAwesomeIcons.key),
                            label: const Text('Alterar Senha'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showLogoutDialog(context),
                            icon: const Icon(FontAwesomeIcons.rightFromBracket),
                            label: const Text('Sair da Conta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair da Conta'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<UserBloc>().userService.logout();
                // TODO: Navegar para tela de login
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Você foi desconectado')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
