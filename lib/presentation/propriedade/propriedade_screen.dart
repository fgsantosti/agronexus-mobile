import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/presentation/propriedade/cadastro_propriedade_screen.dart';
import 'package:agronexus/presentation/propriedade/editar_propriedade_screen.dart';
import 'package:agronexus/presentation/propriedade/detalhes_propriedade_screen.dart';
import 'package:agronexus/presentation/widgets/entity_action_menu.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:agronexus/config/services/showcase_service.dart';
import 'package:agronexus/config/inject_dependencies.dart';

class PropriedadeScreen extends StatefulWidget {
  const PropriedadeScreen({super.key});

  @override
  State<PropriedadeScreen> createState() => _PropriedadeScreenState();
}

class _PropriedadeScreenState extends State<PropriedadeScreen> {
  final ShowcaseService _showcaseService = getIt<ShowcaseService>();
  final GlobalKey _fabKey = GlobalKey();
  bool _showcaseChecked = false; // Flag para evitar verificação múltipla

  bool _isInitialized = false;
  List<PropriedadeEntity>? _cachedPropriedades; // Cache local das propriedades

  @override
  void initState() {
    super.initState();
    _loadPropriedades();

    // Verificar e iniciar showcase após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_showcaseChecked) {
        _checkAndStartShowcase();
      }
    });
  }

  Future<void> _checkAndStartShowcase() async {
    _showcaseChecked = true;
    final showcaseCompleted = await _showcaseService.isPropriedadeShowcaseCompleted();

    if (!showcaseCompleted && mounted) {
      // Pequeno delay para garantir que tudo foi renderizado
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        ShowCaseWidget.of(context).startShowCase([_fabKey]);
      }
    }
  }

  void _loadPropriedades() {
    context.read<PropriedadeBlocNew>().add(
          const LoadPropriedadesEvent(),
        );
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Propriedades',
        showBack: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadPropriedades(),
        child: BlocListener<PropriedadeBlocNew, PropriedadeState>(
          listener: (context, state) {
            // Cache das propriedades para preservar estado
            if (state is PropriedadesLoaded) {
              _cachedPropriedades = state.propriedades;
            }
            // Tratar sucesso na exclusão
            else if (state is PropriedadeDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Propriedade excluída com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recarregar a lista de propriedades
              _loadPropriedades();
            }
            // Recarregar após criação ou edição
            else if (state is PropriedadeCreated || state is PropriedadeUpdated) {
              _loadPropriedades();
            }
            // Apenas escutar erros e outros estados relevantes
            else if (state is PropriedadeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<PropriedadeBlocNew, PropriedadeState>(
            builder: (context, state) {
              // Se não foi inicializado e não está carregando, forçar carregamento
              if (!_isInitialized && state is! PropriedadeLoading) {
                _loadPropriedades();
                return const Center(child: CircularProgressIndicator());
              }

              // Mostrar erro se houver
              if (state is PropriedadeError && _cachedPropriedades == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar propriedades',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPropriedades,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              // Usar dados do estado atual ou cache
              List<PropriedadeEntity>? propriedadesToShow;
              if (state is PropriedadesLoaded) {
                propriedadesToShow = state.propriedades;
              } else if (_cachedPropriedades != null) {
                propriedadesToShow = _cachedPropriedades;
              }

              if (propriedadesToShow != null) {
                if (propriedadesToShow.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma propriedade encontrada',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cadastre a primeira propriedade',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: propriedadesToShow.length,
                  itemBuilder: (context, index) {
                    final propriedade = propriedadesToShow![index];
                    return _buildPropriedadeCard(propriedade);
                  },
                );
              }

              // Para qualquer outro estado, mostrar loading
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando propriedades...'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: Showcase(
        key: _fabKey,
        title: '➕ Cadastrar Propriedade',
        description: 'Toque aqui para cadastrar sua primeira propriedade rural. '
            'É necessário ter pelo menos uma propriedade cadastrada para usar o sistema.',
        targetShapeBorder: const CircleBorder(),
        onTargetClick: () async {
          // Marcar como completo e navegar
          await _showcaseService.setPropriedadeShowcaseCompleted();
          if (mounted) {
            ShowCaseWidget.of(context).dismiss();
            _navegarParaCadastro();
          }
        },
        disposeOnTap: true,
        onToolTipClick: () async {
          await _showcaseService.setPropriedadeShowcaseCompleted();
        },
        child: FloatingActionButton(
          heroTag: 'fabPropriedades',
          backgroundColor: Colors.green.shade600,
          onPressed: () async {
            await _showcaseService.setPropriedadeShowcaseCompleted();
            _navegarParaCadastro();
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPropriedadeCard(PropriedadeEntity propriedade) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalhes(propriedade),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.home_work, color: Colors.green.shade600, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          propriedade.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          propriedade.localizacao,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  EntityActionMenu(
                    onEdit: () => _navegarParaEdicao(propriedade),
                    onDelete: () => _confirmarExclusao(propriedade),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Área Total',
                      '${propriedade.areaTotalHa} ha',
                      Icons.landscape,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      'Status',
                      propriedade.ativa ? 'Ativa' : 'Inativa',
                      Icons.circle,
                      propriedade.ativa ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Animais',
                      '${propriedade.totalAnimais}',
                      Icons.pets,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      'Lotes',
                      '${propriedade.totalLotes}',
                      Icons.grid_view,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navegarParaCadastro() async {
    final bloc = context.read<PropriedadeBlocNew>();
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: const CadastroPropriedadeScreen(),
        ),
      ),
    );

    // Se o cadastro foi bem-sucedido ou se não temos certeza, recarregar a lista
    if (resultado == true || resultado == null) {
      _loadPropriedades();
    }
  }

  void _navegarParaEdicao(PropriedadeEntity propriedade) async {
    final bloc = context.read<PropriedadeBlocNew>();
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: EditarPropriedadeScreen(propriedade: propriedade),
        ),
      ),
    );

    if (resultado == true) {
      _loadPropriedades();
    }
  }

  void _mostrarDetalhes(PropriedadeEntity propriedade) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetalhesPropriedadeScreen(propriedade: propriedade),
      ),
    );
  }

  // _executarAcao removido após padronização com EntityActionMenu

  void _confirmarExclusao(PropriedadeEntity propriedade) {
    // Obter referência ao bloc antes de criar o dialog
    final propriedadeBloc = context.read<PropriedadeBlocNew>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir a propriedade "${propriedade.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              propriedadeBloc.add(DeletePropriedadeEvent(propriedade.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
