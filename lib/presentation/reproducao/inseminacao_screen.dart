import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/presentation/reproducao/cadastro_inseminacao_screen.dart';
import 'package:agronexus/presentation/reproducao/editar_inseminacao_screen.dart';
import 'package:intl/intl.dart';

class InseminacaoScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const InseminacaoScreen({super.key, this.onNavigateToTab});

  @override
  State<InseminacaoScreen> createState() => _InseminacaoScreenState();
}

class _InseminacaoScreenState extends State<InseminacaoScreen> with WidgetsBindingObserver {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isInitialized = false;
  List<InseminacaoEntity>? _cachedInseminacoes; // Cache local das inseminações

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInseminacoes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Recarregar dados quando o app volta para o foreground
    if (state == AppLifecycleState.resumed) {
      print('DEBUG LIFECYCLE - App voltou para foreground, recarregando dados se necessário');
      _recarregarDadosSeNecessario();
    }
  }

  void _recarregarDadosSeNecessario() {
    // Recarregar apenas se os dados estão muito antigos ou se não existem
    if (_cachedInseminacoes == null || _cachedInseminacoes!.isEmpty) {
      print('DEBUG LIFECYCLE - Recarregando dados da InseminacaoScreen');
      _loadInseminacoes();
    }
  }

  void _loadInseminacoes() {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month - 3, 1); // Últimos 3 meses
    context.read<ReproducaoBloc>().add(
          LoadInseminacoesEvent(
            dataInicio: inicio,
            dataFim: now,
          ),
        );
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Permite que a tela seja fechada normalmente
      onPopInvokedWithResult: (didPop, result) {
        // Log para debug
        print('DEBUG NAVEGAÇÃO - PopScope na InseminacaoScreen invocado: didPop=$didPop');

        // Se o pop foi bem sucedido, não precisamos fazer nada adicional
        if (didPop) {
          print('DEBUG NAVEGAÇÃO - Pop foi bem sucedido, voltando para tela anterior');
        }
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => _loadInseminacoes(),
          child: BlocListener<ReproducaoBloc, ReproducaoState>(
            listener: (context, state) {
              // Cache das inseminações para preservar estado
              if (state is InseminacoesLoaded) {
                _cachedInseminacoes = state.inseminacoes;
              }
              // Tratar sucesso na exclusão
              else if (state is InseminacaoDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inseminação excluída com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Recarregar a lista de inseminações
                _loadInseminacoes();
              }
              // Apenas escutar erros e outros estados relevantes
              else if (state is ReproducaoError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
              builder: (context, state) {
                // Se não foi inicializado e não está carregando, forçar carregamento
                if (!_isInitialized && state is! InseminacoesLoading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _loadInseminacoes();
                    }
                  });
                }

                // Mostrar loading apenas se não temos cache e está carregando
                if (state is InseminacoesLoading && _cachedInseminacoes == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ReproducaoError && _cachedInseminacoes == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar inseminações',
                          style: TextStyle(fontSize: 18, color: Colors.red.shade400),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInseminacoes,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }

                // Usar dados do estado atual ou cache
                List<InseminacaoEntity>? inseminacoesToShow;
                if (state is InseminacoesLoaded) {
                  inseminacoesToShow = state.inseminacoes;
                } else if (_cachedInseminacoes != null) {
                  inseminacoesToShow = _cachedInseminacoes;
                }

                if (inseminacoesToShow != null) {
                  if (inseminacoesToShow.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma inseminação encontrada',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Registre a primeira inseminação',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: inseminacoesToShow.length,
                    itemBuilder: (context, index) {
                      final inseminacao = inseminacoesToShow![index];
                      return _buildInseminacaoCard(inseminacao);
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
                      Text('Carregando inseminações...'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onNavigateToTab != null)
              FloatingActionButton.small(
                heroTag: 'fabNavigateToDiagnostico',
                backgroundColor: Colors.orange.shade400,
                onPressed: () => widget.onNavigateToTab!(1), // Aba 1 = Diagnósticos
                child: const Icon(Icons.medical_services, color: Colors.white, size: 20),
              ),
            if (widget.onNavigateToTab != null) const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'fabInseminacao',
              backgroundColor: Colors.pink.shade400,
              onPressed: () => _navegarParaCadastro(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInseminacaoCard(InseminacaoEntity inseminacao) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalhes(inseminacao),
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
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.favorite, color: Colors.pink.shade400, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inseminacao.animal.situacao.isNotEmpty ? inseminacao.animal.situacao : 'Animal ${inseminacao.animal.idAnimal}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'Identificação: ${inseminacao.animal.idAnimal}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Data',
                      _dateFormat.format(inseminacao.dataInseminacao),
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      'Tipo',
                      inseminacao.tipo.label,
                      Icons.science,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              if (inseminacao.reprodutor != null || inseminacao.semenUtilizado != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (inseminacao.reprodutor != null)
                      Expanded(
                        flex: inseminacao.semenUtilizado != null ? 1 : 1,
                        child: _buildInfoChip(
                          'Reprodutor',
                          _truncateText(inseminacao.reprodutor!.situacao.isNotEmpty ? inseminacao.reprodutor!.situacao : 'ID: ${inseminacao.reprodutor!.idAnimal}', 15),
                          Icons.pets,
                          Colors.orange,
                        ),
                      ),
                    if (inseminacao.reprodutor != null && inseminacao.semenUtilizado != null) const SizedBox(width: 8),
                    if (inseminacao.semenUtilizado != null)
                      Expanded(
                        flex: inseminacao.reprodutor != null ? 1 : 1,
                        child: _buildInfoChip(
                          'Sêmen',
                          _truncateText(inseminacao.semenUtilizado!, 15),
                          Icons.local_hospital,
                          Colors.purple,
                        ),
                      ),
                  ],
                ),
              ],
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
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
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
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navegarParaCadastro() async {
    final bloc = context.read<ReproducaoBloc>();
    print('DEBUG LISTAGEM - Navegando para cadastro');
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: const CadastroInseminacaoScreen(),
        ),
      ),
    );
    print('DEBUG LISTAGEM - Retornou da tela de cadastro, resultado: $resultado');

    // Se o cadastro foi bem-sucedido ou se não temos certeza, recarregar a lista
    if (resultado == true || resultado == null) {
      print('DEBUG LISTAGEM - Recarregando lista de inseminações');
      _loadInseminacoes();
    }
  }

  void _navegarParaEdicao(InseminacaoEntity inseminacao) async {
    final bloc = context.read<ReproducaoBloc>();
    print('DEBUG LISTAGEM - Navegando para edição da inseminação ${inseminacao.id}');
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: EditarInseminacaoScreen(inseminacao: inseminacao),
        ),
      ),
    );

    print('DEBUG LISTAGEM - Resultado da edição: $resultado');
    if (resultado == true) {
      print('DEBUG LISTAGEM - Recarregando lista após edição');
      _loadInseminacoes();
    }
  }

  // Método mantido como referência (não usado atualmente)
  // void _navegarParaDiagnostico(InseminacaoEntity inseminacao) async {
  //   final bloc = context.read<ReproducaoBloc>();
  //   print('DEBUG LISTAGEM - Navegando para diagnóstico da inseminação ${inseminacao.id}');
  //   final resultado = await Navigator.of(context).push<bool>(
  //     MaterialPageRoute(
  //       builder: (context) => BlocProvider.value(
  //         value: bloc,
  //         child: CadastroDiagnosticoGestacaoScreen(
  //           inseminacaoSelecionada: inseminacao,
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   print('DEBUG LISTAGEM - Resultado do diagnóstico: $resultado');
  //   if (resultado == true) {
  //     print('DEBUG LISTAGEM - Recarregando lista após diagnóstico');
  //     _loadInseminacoes();
  //   }
  // }

  void _mostrarDetalhes(InseminacaoEntity inseminacao) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.pink.shade400, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Detalhes da Inseminação',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade400,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fechar o modal primeiro
                          _navegarParaEdicao(inseminacao);
                        },
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        color: Colors.blue,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fechar o modal primeiro
                          _confirmarExclusao(inseminacao);
                        },
                        icon: const Icon(Icons.delete),
                        tooltip: 'Excluir',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetalheItem('Animal', inseminacao.animal.situacao.isNotEmpty ? inseminacao.animal.situacao : 'ID: ${inseminacao.animal.idAnimal}'),
                    _buildDetalheItem('Data da Inseminação', _dateFormat.format(inseminacao.dataInseminacao)),
                    _buildDetalheItem('Tipo', inseminacao.tipo.label),
                    if (inseminacao.reprodutor != null)
                      _buildDetalheItem('Reprodutor', inseminacao.reprodutor!.situacao.isNotEmpty ? inseminacao.reprodutor!.situacao : 'ID: ${inseminacao.reprodutor!.idAnimal}'),
                    if (inseminacao.semenUtilizado != null) _buildDetalheItem('Sêmen Utilizado', inseminacao.semenUtilizado!),
                    if (inseminacao.protocoloIatf != null) _buildDetalheItem('Protocolo IATF', inseminacao.protocoloIatf!.nome),
                    if (inseminacao.estacaoMonta != null) _buildDetalheItem('Estação de Monta', inseminacao.estacaoMonta!.nome),
                    if (inseminacao.observacoes != null) _buildDetalheItem('Observações', inseminacao.observacoes!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalheItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200, height: 1),
        ],
      ),
    );
  }

  // Método mantido como referência (não usado atualmente)
  // void _executarAcao(String acao, InseminacaoEntity inseminacao) {
  //   switch (acao) {
  //     case 'detalhes':
  //       _mostrarDetalhes(inseminacao);
  //       break;
  //     case 'editar':
  //       _navegarParaEdicao(inseminacao);
  //       break;
  //     case 'diagnostico':
  //       _navegarParaDiagnostico(inseminacao);
  //       break;
  //     case 'excluir':
  //       _confirmarExclusao(inseminacao);
  //       break;
  //   }
  // }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  void _confirmarExclusao(InseminacaoEntity inseminacao) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir a inseminação do animal '
          '${inseminacao.animal.situacao.isNotEmpty ? inseminacao.animal.situacao : inseminacao.animal.idAnimal}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Usar o contexto da tela principal, não do dialog
              context.read<ReproducaoBloc>().add(DeleteInseminacaoEvent(inseminacao.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
