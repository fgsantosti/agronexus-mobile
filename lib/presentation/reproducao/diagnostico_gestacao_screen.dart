import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:intl/intl.dart';

class DiagnosticoGestacaoScreen extends StatefulWidget {
  const DiagnosticoGestacaoScreen({super.key});

  @override
  State<DiagnosticoGestacaoScreen> createState() => _DiagnosticoGestacaoScreenState();
}

class _DiagnosticoGestacaoScreenState extends State<DiagnosticoGestacaoScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadDiagnosticos(),
        child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
          builder: (context, state) {
            if (state is DiagnosticosGestacaoLoading) {
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

            if (state is DiagnosticosGestacaoLoaded) {
              if (state.diagnosticos.isEmpty) {
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
                itemCount: state.diagnosticos.length,
                itemBuilder: (context, index) {
                  final diagnostico = state.diagnosticos[index];
                  return _buildDiagnosticoCard(diagnostico);
                },
              );
            }

            return const Center(child: Text('Carregando...'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fabDiagnosticoGestacao',
        backgroundColor: Colors.orange.shade400,
        onPressed: () {
          _showAddDiagnosticoDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
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
              if (diagnostico.metodo != null && diagnostico.metodo!.isNotEmpty) ...[
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Diagnóstico'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Animal', 'Animal ${diagnostico.inseminacao.animal.idAnimal}'),
              _buildDetailRow('Resultado', diagnostico.resultado.label),
              _buildDetailRow('Data Diagnóstico', _dateFormat.format(diagnostico.dataDiagnostico)),
              _buildDetailRow('Data Inseminação', _dateFormat.format(diagnostico.inseminacao.dataInseminacao)),
              _buildDetailRow('Tipo Inseminação', diagnostico.inseminacao.tipo.label),
              if (diagnostico.metodo != null && diagnostico.metodo!.isNotEmpty) _buildDetailRow('Método', diagnostico.metodo!),
              if (diagnostico.dataPartoPrevista != null) _buildDetailRow('Parto Previsto', _dateFormat.format(diagnostico.dataPartoPrevista!)),
              if (diagnostico.observacoes != null && diagnostico.observacoes!.isNotEmpty) _buildDetailRow('Observações', diagnostico.observacoes!),
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

  void _showAddDiagnosticoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Diagnóstico'),
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
