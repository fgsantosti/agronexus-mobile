import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_bloc.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_event.dart';
import 'package:agronexus/presentation/bloc/import_export/import_export_state.dart';
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
      body: BlocListener<ImportExportBloc, ImportExportState>(
        listener: (context, state) {
          if (state is ImportacaoSucesso) {
            _showImportResult(context, state.resultado);
          }

          if (state is TemplateSucesso) {
            _shareTemplate(state.templateFile);
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
        child: BlocBuilder<ImportExportBloc, ImportExportState>(
          builder: (context, state) {
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
                                    context.read<ImportExportBloc>().add(const GerarTemplateEvent());
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
                            context.read<ImportExportBloc>().add(ImportarAnimaisEvent(_selectedFile!));
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
                            '• Verifique se não há linhas em branco no meio dos dados',
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
      // Solicitar permissão de armazenamento se necessário
      final status = await Permission.storage.request();

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de acesso ao armazenamento negada'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });

        // Validar o arquivo
        context.read<ImportExportBloc>().add(ValidarArquivoEvent(_selectedFile!));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total de registros: ${resultado.totalRegistros}'),
            Text('Sucessos: ${resultado.sucessos}'),
            Text('Erros: ${resultado.erros}'),
            if (resultado.mensagensErro.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Erros encontrados:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...resultado.mensagensErro.take(5).map((erro) => Text('• $erro')),
              if (resultado.mensagensErro.length > 5) Text('... e mais ${resultado.mensagensErro.length - 5} erros'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (resultado.status == ImportStatus.sucesso) {
                setState(() {
                  _selectedFile = null;
                });
              }
            },
            child: const Text('OK'),
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
}
