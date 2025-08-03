import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/presentation/reproducao/cadastro_inseminacao_screen.dart';
import 'package:intl/intl.dart';

class InseminacaoScreen extends StatefulWidget {
  const InseminacaoScreen({super.key});

  @override
  State<InseminacaoScreen> createState() => _InseminacaoScreenState();
}

class _InseminacaoScreenState extends State<InseminacaoScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadInseminacoes();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadInseminacoes(),
        child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
          builder: (context, state) {
            if (state is InseminacoesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReproducaoError) {
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

            if (state is InseminacoesLoaded) {
              if (state.inseminacoes.isEmpty) {
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
                itemCount: state.inseminacoes.length,
                itemBuilder: (context, index) {
                  final inseminacao = state.inseminacoes[index];
                  return _buildInseminacaoCard(inseminacao);
                },
              );
            }

            return const Center(child: Text('Carregando...'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink.shade400,
        onPressed: () => _navegarParaCadastro(),
        child: const Icon(Icons.add, color: Colors.white),
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
        onTap: () {
          _showInseminacaoDetails(inseminacao);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getTipoColor(inseminacao.tipo),
                    child: Icon(
                      _getTipoIcon(inseminacao.tipo),
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
                          'Animal ${inseminacao.animal.idAnimal}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          inseminacao.tipo.label,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _dateFormat.format(inseminacao.dataInseminacao),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (inseminacao.dataDiagnosticoPrevista != null)
                        Text(
                          'Diag: ${_dateFormat.format(inseminacao.dataDiagnosticoPrevista!)}',
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (inseminacao.reprodutor != null || inseminacao.semenUtilizado != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (inseminacao.reprodutor != null) ...[
                      Icon(Icons.male, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Reprodutor: ${inseminacao.reprodutor!.idAnimal}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (inseminacao.semenUtilizado != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.science, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Sêmen: ${inseminacao.semenUtilizado}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (inseminacao.estacaoMonta != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Estação: ${inseminacao.estacaoMonta!.nome}',
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

  Color _getTipoColor(TipoInseminacao tipo) {
    switch (tipo) {
      case TipoInseminacao.natural:
        return Colors.green;
      case TipoInseminacao.ia:
        return Colors.blue;
      case TipoInseminacao.iatf:
        return Colors.purple;
    }
  }

  IconData _getTipoIcon(TipoInseminacao tipo) {
    switch (tipo) {
      case TipoInseminacao.natural:
        return Icons.nature;
      case TipoInseminacao.ia:
        return Icons.science;
      case TipoInseminacao.iatf:
        return Icons.schedule;
    }
  }

  void _showInseminacaoDetails(InseminacaoEntity inseminacao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes da Inseminação'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Animal', 'Animal ${inseminacao.animal.idAnimal}'),
              _buildDetailRow('Tipo', inseminacao.tipo.label),
              _buildDetailRow('Data', _dateFormat.format(inseminacao.dataInseminacao)),
              if (inseminacao.reprodutor != null) _buildDetailRow('Reprodutor', inseminacao.reprodutor!.idAnimal),
              if (inseminacao.semenUtilizado != null) _buildDetailRow('Sêmen', inseminacao.semenUtilizado!),
              if (inseminacao.estacaoMonta != null) _buildDetailRow('Estação de Monta', inseminacao.estacaoMonta!.nome),
              if (inseminacao.protocoloIatf != null) _buildDetailRow('Protocolo IATF', inseminacao.protocoloIatf!.nome),
              if (inseminacao.dataDiagnosticoPrevista != null) _buildDetailRow('Diagnóstico Previsto', _dateFormat.format(inseminacao.dataDiagnosticoPrevista!)),
              if (inseminacao.observacoes != null && inseminacao.observacoes!.isNotEmpty) _buildDetailRow('Observações', inseminacao.observacoes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar edição
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edição em desenvolvimento')),
              );
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
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

    print('DEBUG LISTAGEM - Resultado recebido: $resultado');
    // Se o cadastro foi bem-sucedido, recarrega a lista
    if (resultado == true) {
      print('DEBUG LISTAGEM - Recarregando lista de inseminações');
      _loadInseminacoes();
    }
  }
}
