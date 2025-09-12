import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_bloc.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_event.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_state.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_event.dart';
import 'package:agronexus/domain/models/import_result_entity.dart';

class ImportAnimalsScreen extends StatefulWidget {
  const ImportAnimalsScreen({super.key});

  @override
  State<ImportAnimalsScreen> createState() => _ImportAnimalsScreenState();
}

class _ImportAnimalsScreenState extends State<ImportAnimalsScreen> {
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Animais'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ImportExportBloc, ImportExportState>(
            listener: (context, state) {
              if (state is ImportacaoSucesso) {
                _showImportResult(context, state.resultado);
                // Recarregar dados do AnimalBloc após importação bem-sucedida
                if (state.resultado.status == ImportStatus.sucesso && state.resultado.sucessos > 0) {
                  context.read<AnimalBloc>().add(const LoadAnimaisEvent());
                }
              }

              if (state is ImportacaoSucessoParcial) {
                _showImportResultParcial(context, state.resultado, state.mensagemPersonalizada);
                // Sempre recarregar a lista, pois pode haver mudanças
                context.read<AnimalBloc>().add(const LoadAnimaisEvent());
              }

              if (state is TemplateSucesso) {
                _shareTemplate(state.templateFile);
              }

              if (state is ImportExportError) {
                _showErrorDialog(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<ImportExportBloc, ImportExportState>(
          builder: (context, state) {
            // Capturar o ImportExportBloc aqui para usar nos botões
            final importExportBloc = context.read<ImportExportBloc>();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Seção de template
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Template de Importação',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Baixe o template para facilitar a importação dos seus animais.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: state is ImportExportLoading
                                ? null
                                : () {
                                    importExportBloc.add(const GerarTemplateEvent());
                                  },
                            icon: const Icon(Icons.download),
                            label: const Text('Baixar Template'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Seção de seleção de arquivo
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selecionar Arquivo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Escolha o arquivo Excel (.xlsx) com os dados dos animais.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedFile != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.file_present, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedFile!.path.split('/').last,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          ElevatedButton.icon(
                            onPressed: state is ImportExportLoading ? null : _selectFile,
                            icon: const Icon(Icons.upload_file),
                            label: Text(_selectedFile == null ? 'Selecionar Arquivo' : 'Alterar Arquivo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão de importar
                  ElevatedButton(
                    onPressed: _selectedFile == null || state is ImportExportLoading
                        ? null
                        : () {
                            importExportBloc.add(ImportarAnimaisEvent(_selectedFile!));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is ImportExportLoading
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
                              Text('Processando...'),
                            ],
                          )
                        : const Text(
                            'Importar Animais',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Informações adicionais
                  Card(
                    color: Colors.orange.withOpacity(0.1),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Importante',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Use sempre o template fornecido\n'
                            '• Certifique-se de que todos os campos obrigatórios estejam preenchidos\n'
                            '• O arquivo deve estar no formato .xlsx (Excel)\n'
                            '• Verifique se não há linhas em branco no meio dos dados\n'
                            '• Animais com o mesmo identificador serão ignorados (duplicados)',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      // Para Android 13+ não precisamos mais solicitar permissão de storage
      // O FilePicker gerencia automaticamente as permissões necessárias

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });

        // Validar o arquivo
        context.read<ImportExportBloc>().add(ValidarArquivoEvent(_selectedFile!));
      }
    } catch (e) {
      print('Erro ao selecionar arquivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar arquivo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportResult(BuildContext context, ImportResultEntity resultado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              resultado.status == ImportStatus.sucesso ? Icons.check_circle : Icons.error,
              color: resultado.status == ImportStatus.sucesso ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(resultado.status.label),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estatísticas em cards organizados
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Total de registros', resultado.totalRegistros.toString(), Icons.description),
                    if (resultado.sucessos > 0) _buildStatRow('Importados', resultado.sucessos.toString(), Icons.check_circle, Colors.green),
                    if (resultado.duplicados > 0) _buildStatRow('Duplicados ignorados', resultado.duplicados.toString(), Icons.content_copy, Colors.orange),
                    if (resultado.erros > 0) _buildStatRow('Com erro', resultado.erros.toString(), Icons.error, Colors.red),
                  ],
                ),
              ),

              if (resultado.mensagensErro.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Erros encontrados:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: resultado.mensagensErro
                          .take(10)
                          .map(
                            (erro) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, size: 16, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(erro, style: const TextStyle(fontSize: 12))),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                if (resultado.mensagensErro.length > 10)
                  Text(
                    '... e mais ${resultado.mensagensErro.length - 10} erros',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          if (resultado.status == ImportStatus.sucesso && resultado.sucessos > 0)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/animais');
              },
              icon: const Icon(Icons.pets),
              label: const Text('Ver Animais'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedFile = null;
              });
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareTemplate(File templateFile) async {
    try {
      await Share.shareXFiles([XFile(templateFile.path)]);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template baixado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao compartilhar template: $e')),
      );
    }
  }

  void _showImportResultParcial(BuildContext context, ImportResultEntity resultado, String mensagemPersonalizada) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              resultado.sucessos > 0 ? Icons.check_circle_outline : Icons.info_outline,
              color: resultado.sucessos > 0 ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Importação Concluída',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: resultado.sucessos > 0 ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensagem principal
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: resultado.sucessos > 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: resultado.sucessos > 0 ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  mensagemPersonalizada,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Estatísticas detalhadas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Total de registros', resultado.totalRegistros.toString(), Icons.description),
                    if (resultado.sucessos > 0) _buildStatRow('Importados', resultado.sucessos.toString(), Icons.check_circle, Colors.green),
                    if (resultado.duplicados > 0) _buildStatRow('Duplicados ignorados', resultado.duplicados.toString(), Icons.content_copy, Colors.orange),
                    if (resultado.erros > 0) _buildStatRow('Com erro', resultado.erros.toString(), Icons.error, Colors.red),
                  ],
                ),
              ),

              if (resultado.mensagensErro.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Erros encontrados:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: resultado.mensagensErro
                          .take(10)
                          .map(
                            (erro) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, size: 16, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(erro, style: const TextStyle(fontSize: 12))),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                if (resultado.mensagensErro.length > 10)
                  Text(
                    '... e mais ${resultado.mensagensErro.length - 10} erros',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          if (resultado.sucessos > 0)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/animais');
              },
              icon: const Icon(Icons.pets),
              label: const Text('Ver Animais'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedFile = null;
              });
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    // Capturar o ImportExportBloc antes de mostrar o dialog
    final importExportBloc = context.read<ImportExportBloc>();

    // Personalizar mensagem de erro para torná-la mais amigável
    String friendlyMessage = errorMessage;
    String title = 'Erro na Importação';
    IconData icon = Icons.error;

    if (errorMessage.contains('Importação concluída')) {
      title = 'Importação Concluída';
      icon = Icons.info;
      friendlyMessage = errorMessage;
    } else if (errorMessage.contains('Colunas obrigatórias')) {
      title = 'Arquivo Inválido';
      friendlyMessage = 'O arquivo não possui todas as colunas obrigatórias. Verifique se está usando o template correto.';
    } else if (errorMessage.contains('Erro ao processar arquivo')) {
      title = 'Erro no Arquivo';
      friendlyMessage = 'Não foi possível processar o arquivo. Verifique se é um arquivo Excel válido (.xlsx).';
    } else if (errorMessage.contains('Erro de validação')) {
      title = 'Dados Inválidos';
      friendlyMessage = 'Alguns dados no arquivo não estão no formato correto. Verifique as informações e tente novamente.';
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  friendlyMessage,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dicas para resolver:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Verifique se está usando o template oficial\n'
                '• Certifique-se que todas as colunas obrigatórias estão preenchidas\n'
                '• Verifique se o arquivo é um Excel válido (.xlsx)\n'
                '• Tente baixar um novo template e preencher novamente',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Gerar template usando o bloc capturado
              importExportBloc.add(const GerarTemplateEvent());
            },
            icon: const Icon(Icons.download),
            label: const Text('Baixar Template'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
