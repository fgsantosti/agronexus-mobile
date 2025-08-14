import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/presentation/reproducao/cadastro_parto_screen.dart';
import 'package:agronexus/presentation/reproducao/editar_parto_screen.dart';
import 'package:intl/intl.dart';

class PartoScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const PartoScreen({super.key, this.onNavigateToTab});

  @override
  State<PartoScreen> createState() => _PartoScreenState();
}

class _PartoScreenState extends State<PartoScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isInitialized = false;
  List<PartoEntity>? _cachedPartos; // Cache local dos partos

  @override
  void initState() {
    super.initState();
    _loadPartos();
  }

  void _loadPartos() {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month - 6, 1); // Últimos 6 meses
    context.read<ReproducaoBloc>().add(
          LoadPartosEvent(
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
        onRefresh: () async => _loadPartos(),
        child: BlocListener<ReproducaoBloc, ReproducaoState>(
          listener: (context, state) {
            // Cache dos partos para preservar estado
            if (state is PartosLoaded) {
              _cachedPartos = state.partos;
            }
            // Tratar sucesso na criação
            else if (state is PartoCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parto cadastrado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recarregar a lista de partos
              _loadPartos();
            }
            // Tratar sucesso na atualização
            else if (state is PartoUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parto atualizado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recarregar a lista de partos
              _loadPartos();
            }
            // Tratar sucesso na exclusão
            else if (state is PartoDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parto excluído com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recarregar a lista de partos
              _loadPartos();
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
              if (!_isInitialized && state is! PartosLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _loadPartos();
                  }
                });
              }

              // Mostrar loading apenas se não temos cache e está carregando
              if (state is PartosLoading && _cachedPartos == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReproducaoError && _cachedPartos == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar partos',
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
                        onPressed: _loadPartos,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              // Usar dados do cache ou dados atuais do estado
              final partos = _cachedPartos ?? [];

              if (partos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.child_care_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum parto encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registre o primeiro parto',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: partos.length,
                itemBuilder: (context, index) {
                  final parto = partos[index];
                  return _buildPartoCard(parto);
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
              heroTag: 'fabNavigateToDiagnostico',
              backgroundColor: Colors.orange.shade400,
              onPressed: () => widget.onNavigateToTab!(2), // Aba 2 = Diagnóstico de Gestação
              child: const Icon(Icons.medical_services, color: Colors.white, size: 20),
            ),
          if (widget.onNavigateToTab != null) const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'fabParto',
            backgroundColor: Colors.green.shade400,
            onPressed: () {
              _showAddPartoDialog();
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPartoCard(PartoEntity parto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showPartoDetails(parto);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getResultadoColor(parto.resultado),
                    child: Icon(
                      _getResultadoIcon(parto.resultado),
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
                          'Animal ${parto.mae.idAnimal}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          parto.resultado.label,
                          style: TextStyle(
                            color: _getResultadoColor(parto.resultado),
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
                        _dateFormat.format(parto.dataParto),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (parto.pesoNascimento != null)
                        Text(
                          '${parto.pesoNascimento!.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            color: Colors.blue.shade600,
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
                  Icon(Icons.medical_services, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Dificuldade: ${parto.dificuldade.label}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  if (parto.bezerro != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.child_care, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Cria: ${parto.bezerro!.idAnimal}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getResultadoColor(ResultadoParto resultado) {
    switch (resultado) {
      case ResultadoParto.nascidoVivo:
        return Colors.green;
      case ResultadoParto.aborto:
        return Colors.red;
      case ResultadoParto.natimorto:
        return Colors.orange;
    }
  }

  IconData _getResultadoIcon(ResultadoParto resultado) {
    switch (resultado) {
      case ResultadoParto.nascidoVivo:
        return Icons.child_care;
      case ResultadoParto.aborto:
      case ResultadoParto.natimorto:
        return Icons.close;
    }
  }

  void _showPartoDetails(PartoEntity parto) {
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
                    backgroundColor: _getResultadoColor(parto.resultado),
                    child: Icon(
                      _getResultadoIcon(parto.resultado),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Detalhes do Parto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade400,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fechar o modal primeiro
                          _editarParto(parto);
                        },
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        color: Colors.blue,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fechar o modal primeiro
                          _confirmDelete(parto);
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
                    _buildDetalheItem('Mãe', 'Animal ${parto.mae.idAnimal}'),
                    _buildDetalheItem('Data do Parto', _dateFormat.format(parto.dataParto)),
                    _buildDetalheItem('Resultado', parto.resultado.label),
                    _buildDetalheItem('Dificuldade', parto.dificuldade.label),
                    if (parto.bezerro != null) _buildDetalheItem('Cria', 'Animal ${parto.bezerro!.idAnimal}'),
                    if (parto.pesoNascimento != null) _buildDetalheItem('Peso Nascimento', '${parto.pesoNascimento!.toStringAsFixed(1)} kg'),
                    if (parto.observacoes != null && parto.observacoes!.isNotEmpty) _buildDetalheItem('Observações', parto.observacoes!),
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

  void _editarParto(PartoEntity parto) async {
    final reproducaoBloc = context.read<ReproducaoBloc>();
    final animalBloc = context.read<AnimalBloc>();
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: reproducaoBloc),
            BlocProvider.value(value: animalBloc),
          ],
          child: EditarPartoScreen(parto: parto),
        ),
      ),
    );

    // Se retornou true, significa que foi editado com sucesso
    if (resultado == true) {
      _loadPartos(); // Recarregar a lista
    }
  }

  void _confirmDelete(PartoEntity parto) {
    // Salvar referência ao BLoC antes de abrir o dialog
    final reproducaoBloc = context.read<ReproducaoBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o parto do animal ${parto.mae.idAnimal}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              reproducaoBloc.add(
                DeletePartoEvent(parto.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showAddPartoDialog() {
    final reproducaoBloc = context.read<ReproducaoBloc>();
    final animalBloc = context.read<AnimalBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: reproducaoBloc),
            BlocProvider.value(value: animalBloc),
          ],
          child: const CadastroPartoScreen(),
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Recarregar a lista se o cadastro foi bem-sucedido
        _loadPartos();
      }
    });
  }
}
