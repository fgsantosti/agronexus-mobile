import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_event.dart';
import 'package:agronexus/presentation/bloc/animal/animal_state.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_bloc.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_event.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_state.dart';
import 'package:agronexus/domain/models/export_options_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';

class ExportAnimalsScreen extends StatefulWidget {
  const ExportAnimalsScreen({super.key});

  @override
  State<ExportAnimalsScreen> createState() => _ExportAnimalsScreenState();
}

class _ExportAnimalsScreenState extends State<ExportAnimalsScreen> {
  bool _incluirEstatisticas = true;
  bool _incluirGenealogia = true;
  String _formatoData = 'dd/MM/yyyy';

  @override
  void initState() {
    super.initState();
    context.read<AnimalBloc>().add(const LoadAnimaisEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Animais'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<ImportExportBloc, ImportExportState>(
        listener: (context, state) {
          if (state is ExportacaoSucesso) {
            _shareExportedFile(state.caminhoArquivo);
          }

          if (state is ImportExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AnimalBloc, AnimalState>(
          builder: (context, animalState) {
            if (animalState is AnimalLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (animalState is AnimalError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(animalState.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AnimalBloc>().add(const LoadAnimaisEvent());
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            }

            final animais = animalState is AnimaisLoaded ? animalState.animais : <AnimalEntity>[];

            return BlocBuilder<ImportExportBloc, ImportExportState>(
              builder: (context, exportState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Estatísticas dos animais
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumo dos Animais',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total',
                                      animais.length.toString(),
                                      Icons.pets,
                                      Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Machos',
                                      animais.where((a) => a.sexo.value == 'M').length.toString(),
                                      Icons.male,
                                      Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Fêmeas',
                                      animais.where((a) => a.sexo.value == 'F').length.toString(),
                                      Icons.female,
                                      Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Opções de exportação
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Opções de Exportação',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                title: const Text('Incluir Estatísticas'),
                                subtitle: const Text('Adiciona uma planilha com estatísticas gerais'),
                                value: _incluirEstatisticas,
                                onChanged: (value) {
                                  setState(() {
                                    _incluirEstatisticas = value ?? true;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Incluir Genealogia'),
                                subtitle: const Text('Adiciona colunas de pai e mãe'),
                                value: _incluirGenealogia,
                                onChanged: (value) {
                                  setState(() {
                                    _incluirGenealogia = value ?? true;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Formato de Data',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _formatoData,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('dd/MM/yyyy')),
                                  DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/dd/yyyy')),
                                  DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('yyyy-MM-dd')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _formatoData = value ?? 'dd/MM/yyyy';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botão de exportar
                      ElevatedButton(
                        onPressed: animais.isEmpty || exportState is ImportExportLoading
                            ? null
                            : () {
                                final options = ExportOptionsEntity(
                                  format: ExportFormat.xlsx,
                                  includeInactives: _incluirEstatisticas,
                                  selectedFields: [
                                    'identificacao',
                                    'nome',
                                    'raca',
                                    'sexo',
                                    'data_nascimento',
                                    'status',
                                    if (_incluirGenealogia) 'pai',
                                    if (_incluirGenealogia) 'mae',
                                  ],
                                );

                                context.read<ImportExportBloc>().add(
                                      ExportarAnimaisEvent(animais, options),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: exportState is ImportExportLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Gerando Arquivo...'),
                                ],
                              )
                            : const Text(
                                'Exportar para Excel',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),

                      if (animais.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Nenhum animal encontrado para exportar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareExportedFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo Excel exportado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao compartilhar arquivo: $e')),
      );
    }
  }
}
