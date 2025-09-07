import 'dart:io';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/import_result_entity.dart';
import 'package:agronexus/domain/models/export_options_entity.dart';
import 'package:agronexus/domain/repositories/remote/import_export/import_export_remote_repository.dart';

class ImportExportService {
  final ImportExportRepository _repository;

  ImportExportService(this._repository);

  Future<ImportResultEntity> importarAnimaisExcel(File arquivo) async {
    return await _repository.importarAnimaisExcel(arquivo);
  }

  Future<String> exportarAnimaisExcel(List<AnimalEntity> animais, ExportOptionsEntity options) async {
    return await _repository.exportarAnimaisExcel(animais, options);
  }

  Future<File> gerarTemplateImportacao() async {
    return await _repository.gerarTemplateImportacao();
  }

  Future<bool> validarArquivoImportacao(File arquivo) async {
    return await _repository.validarArquivoImportacao(arquivo);
  }
}
