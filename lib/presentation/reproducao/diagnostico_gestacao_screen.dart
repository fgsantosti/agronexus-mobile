import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/presentation/reproducao/cadastro_diagnostico_gestacao_screen.dart';
import 'package:agronexus/presentation/reproducao/editar_diagnostico_gestacao_screen.dart';
import 'package:intl/intl.dart';

class DiagnosticoGestacaoScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const DiagnosticoGestacaoScreen({super.key, this.onNavigateToTab});

  @override
  State<DiagnosticoGestacaoScreen> createState() => _DiagnosticoGestacaoScreenState();
}

class _DiagnosticoGestacaoScreenState extends State<DiagnosticoGestacaoScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isInitialized = false;
  List<DiagnosticoGestacaoEntity>? _cachedDiagnosticos; // Cache local dos diagnósticos

  @override
  void initState() {
    super.initState();
    _loadDiagnosticos();
  }

  void _loadDiagnosticos() {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month - 3, 1); // Últimos 3 meses
    context.read<ReproducaoBloc>().add(
          LoadDiagnosticosGestacaoEvent(
            dataInicio: inicio,
            dataFim: now,
          ),
        );
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadDiagnosticos(),
        child: BlocListener<ReproducaoBloc, ReproducaoState>(
          listener: (context, state) {
            // Cache dos diagnósticos para preservar estado
            if (state is DiagnosticosGestacaoLoaded) {
              _cachedDiagnosticos = state.diagnosticos;
            }
            // Tratar sucesso na criação
            else if (state is DiagnosticoGestacaoCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diagnóstico cadastrado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recarregar a lista de diagnósticos
              _loadDiagnosticos();
            }
            // Tratar sucesso na atualização
            else if (state is DiagnosticoGestacaoUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diagnóstico atualizado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recarregar a lista de diagnósticos
              _loadDiagnosticos();
            }
            // Tratar sucesso na exclusão
            else if (state is DiagnosticoGestacaoDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diagnóstico excluído com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recarregar a lista de diagnósticos
              _loadDiagnosticos();
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
              if (!_isInitialized && state is! DiagnosticosGestacaoLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _loadDiagnosticos();
                  }
                });
              }

              // Mostrar loading apenas se não temos cache e está carregando
              if (state is DiagnosticosGestacaoLoading && _cachedDiagnosticos == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReproducaoError && _cachedDiagnosticos == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar diagnósticos',
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
                        onPressed: _loadDiagnosticos,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              // Usar dados do cache ou dados atuais do estado
              final diagnosticos = _cachedDiagnosticos ?? [];

              if (diagnosticos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum diagnóstico encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registre o primeiro diagnóstico',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: diagnosticos.length,
                itemBuilder: (context, index) {
                  final diagnostico = diagnosticos[index];
                  return _buildDiagnosticoCard(diagnostico);
                },
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
              heroTag: 'fabNavigateToInseminacao',
              backgroundColor: Colors.pink.shade400,
              onPressed: () => widget.onNavigateToTab!(0), // Aba 0 = Inseminações
              child: const Icon(Icons.favorite, color: Colors.white, size: 20),
            ),
          if (widget.onNavigateToTab != null) const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'fabDiagnosticoGestacao',
            backgroundColor: Colors.orange.shade400,
            onPressed: () {
              _showAddDiagnosticoDialog();
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoCard(DiagnosticoGestacaoEntity diagnostico) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showDiagnosticoDetails(diagnostico);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getResultadoColor(diagnostico.resultado),
                    child: Icon(
                      _getResultadoIcon(diagnostico.resultado),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Animal ${diagnostico.inseminacao.animal.idAnimal}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          diagnostico.resultado.label,
                          style: TextStyle(
                            color: _getResultadoColor(diagnostico.resultado),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _dateFormat.format(diagnostico.dataDiagnostico),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (diagnostico.dataPartoPrevista != null)
                        Text(
                          'Parto: ${_dateFormat.format(diagnostico.dataPartoPrevista!)}',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Inseminação: ${_dateFormat.format(diagnostico.inseminacao.dataInseminacao)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.science, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    diagnostico.inseminacao.tipo.label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (diagnostico.metodo.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Método: ${diagnostico.metodo}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
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

  Color _getResultadoColor(ResultadoDiagnostico resultado) {
    switch (resultado) {
      case ResultadoDiagnostico.positivo:
        return Colors.green;
      case ResultadoDiagnostico.negativo:
        return Colors.red;
      case ResultadoDiagnostico.inconclusivo:
        return Colors.orange;
    }
  }

  IconData _getResultadoIcon(ResultadoDiagnostico resultado) {
    switch (resultado) {
      case ResultadoDiagnostico.positivo:
        return Icons.check;
      case ResultadoDiagnostico.negativo:
        return Icons.close;
      case ResultadoDiagnostico.inconclusivo:
        return Icons.help;
    }
  }

  void _showDiagnosticoDetails(DiagnosticoGestacaoEntity diagnostico) {
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
                  CircleAvatar(
                    backgroundColor: _getResultadoColor(diagnostico.resultado),
                    child: Icon(
                      _getResultadoIcon(diagnostico.resultado),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Detalhes do Diagnóstico',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade400,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fechar o modal primeiro
                          _editarDiagnostico(diagnostico);
                        },
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        color: Colors.blue,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fechar o modal primeiro
                          _confirmDelete(diagnostico);
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
                    _buildDetalheItem('Animal', diagnostico.inseminacao.animal.situacao.isNotEmpty ? diagnostico.inseminacao.animal.situacao : 'ID: ${diagnostico.inseminacao.animal.idAnimal}'),
                    _buildDetalheItem('Resultado', diagnostico.resultado.label),
                    _buildDetalheItem('Data do Diagnóstico', _dateFormat.format(diagnostico.dataDiagnostico)),
                    _buildDetalheItem('Data da Inseminação', _dateFormat.format(diagnostico.inseminacao.dataInseminacao)),
                    _buildDetalheItem('Tipo de Inseminação', diagnostico.inseminacao.tipo.label),
                    if (diagnostico.metodo.isNotEmpty) _buildDetalheItem('Método de Diagnóstico', diagnostico.metodo),
                    if (diagnostico.dataPartoPrevista != null) _buildDetalheItem('Data Prevista do Parto', _dateFormat.format(diagnostico.dataPartoPrevista!)),
                    if (diagnostico.observacoes.isNotEmpty) _buildDetalheItem('Observações', diagnostico.observacoes),
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

  void _editarDiagnostico(DiagnosticoGestacaoEntity diagnostico) async {
    final bloc = context.read<ReproducaoBloc>();
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: EditarDiagnosticoGestacaoScreen(diagnostico: diagnostico),
        ),
      ),
    );

    // Se retornou true, significa que foi editado com sucesso
    if (resultado == true) {
      _loadDiagnosticos(); // Recarregar a lista
    }
  }

  void _confirmDelete(DiagnosticoGestacaoEntity diagnostico) {
    // Salvar referência ao BLoC antes de abrir o dialog
    final reproducaoBloc = context.read<ReproducaoBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o diagnóstico do animal ${diagnostico.inseminacao.animal.idAnimal}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              reproducaoBloc.add(
                DeleteDiagnosticoGestacaoEvent(diagnostico.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showAddDiagnosticoDialog() {
    final bloc = context.read<ReproducaoBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: const CadastroDiagnosticoGestacaoScreen(),
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Recarregar a lista se o cadastro foi bem-sucedido
        _loadDiagnosticos();
      }
    });
  }
}
