import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:intl/intl.dart';

class PartoScreen extends StatefulWidget {
  const PartoScreen({super.key});

  @override
  State<PartoScreen> createState() => _PartoScreenState();
}

class _PartoScreenState extends State<PartoScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadPartos(),
        child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
          builder: (context, state) {
            if (state is PartosLoading) {
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

            if (state is PartosLoaded) {
              if (state.partos.isEmpty) {
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
                itemCount: state.partos.length,
                itemBuilder: (context, index) {
                  final parto = state.partos[index];
                  return _buildPartoCard(parto);
                },
              );
            }

            return const Center(child: Text('Carregando...'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade400,
        onPressed: () {
          _showAddPartoDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Parto'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Mãe', 'Animal ${parto.mae.idAnimal}'),
              _buildDetailRow('Data do Parto', _dateFormat.format(parto.dataParto)),
              _buildDetailRow('Resultado', parto.resultado.label),
              _buildDetailRow('Dificuldade', parto.dificuldade.label),
              if (parto.bezerro != null) _buildDetailRow('Cria', 'Animal ${parto.bezerro!.idAnimal}'),
              if (parto.pesoNascimento != null) _buildDetailRow('Peso Nascimento', '${parto.pesoNascimento!.toStringAsFixed(1)} kg'),
              if (parto.observacoes != null && parto.observacoes!.isNotEmpty) _buildDetailRow('Observações', parto.observacoes!),
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
            width: 120,
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

  void _showAddPartoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Parto'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
