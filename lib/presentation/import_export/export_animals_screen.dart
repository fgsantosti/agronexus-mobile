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
import 'package:agronexus/domain/models/opcoes_cadastro_animal.dart';

class ExportAnimalsScreen extends StatefulWidget {
  const ExportAnimalsScreen({super.key});

  @override
  State<ExportAnimalsScreen> createState() => _ExportAnimalsScreenState();
}

class _ExportAnimalsScreenState extends State<ExportAnimalsScreen> {
  bool _incluirEstatisticas = true;
  bool _incluirGenealogia = true;
  String _formatoData = 'dd/MM/yyyy';

  // Filtros
  PropriedadeSimples? _propriedadeSelecionada;
  OpcoesCadastroAnimal? _opcoesCadastro;

  @override
  void initState() {
    super.initState();
    // Carregar apenas opções de cadastro para filtros
    context.read<AnimalBloc>().add(const LoadOpcoesCadastroEvent());
    // Não precisamos mais carregar animais localmente - a API fará isso
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Animais'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ImportExportBloc, ImportExportState>(
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
          ),
          BlocListener<AnimalBloc, AnimalState>(
            listener: (context, state) {
              if (state is OpcoesCadastroLoaded) {
                setState(() {
                  _opcoesCadastro = state.opcoes;
                });
              }
            },
          ),
        ],
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
                        context.read<AnimalBloc>().add(const LoadOpcoesCadastroEvent());
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<ImportExportBloc, ImportExportState>(
              builder: (context, exportState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Seção de Filtros
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Filtrar por Propriedade',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_opcoesCadastro != null)
                                DropdownButtonFormField<PropriedadeSimples>(
                                  value: _propriedadeSelecionada,
                                  decoration: const InputDecoration(
                                    labelText: 'Selecionar Propriedade',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.home),
                                    hintText: 'Todas as minhas propriedades',
                                  ),
                                  items: [
                                    const DropdownMenuItem<PropriedadeSimples>(
                                      value: null,
                                      child: Text('Todas as minhas propriedades'),
                                    ),
                                    ..._opcoesCadastro!.propriedades.map((propriedade) {
                                      return DropdownMenuItem(
                                        value: propriedade,
                                        child: Text(propriedade.nome),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _propriedadeSelecionada = value;
                                    });
                                    _loadAnimaisByPropriedade(value?.id);
                                  },
                                )
                              else
                                const Center(child: CircularProgressIndicator()),
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
                        onPressed: exportState is ImportExportLoading
                            ? null
                            : () {
                                // Criar opções de exportação para a API
                                final options = ExportOptionsEntity(
                                  format: ExportFormat.xlsx,
                                  includeInactives: false, // Não usado pela API
                                  selectedFields: [], // Não usado pela API
                                  incluirGenealogia: _incluirGenealogia,
                                  incluirEstatisticas: _incluirEstatisticas,
                                  formatoData: _formatoData,
                                  propriedadeId: _propriedadeSelecionada?.id,
                                  status: 'ativo', // Por padrão, só animais ativos
                                );

                                print('=== EXPORT DEBUG: Exportando via API com propriedadeId: ${options.propriedadeId}');
                                
                                // Usar a nova API em vez do método local
                                context.read<ImportExportBloc>().add(
                                      ExportarAnimaisViaAPIEvent(options),
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

                      if (exportState is ImportExportLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Buscando dados na API e gerando arquivo Excel...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue,
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

  void _loadAnimaisByPropriedade(String? propriedadeId) {
    print('=== EXPORT DEBUG: _loadAnimaisByPropriedade chamado com propriedadeId: $propriedadeId');
    
    // Não precisamos mais carregar dados localmente - apenas armazenar a seleção
    setState(() {
      // A propriedade selecionada já foi atualizada no onChanged do dropdown
    });
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
