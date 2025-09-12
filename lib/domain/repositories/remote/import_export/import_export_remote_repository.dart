import 'dart:io';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/import_result_entity.dart';
import 'package:agronexus/domain/models/export_options_entity.dart';

abstract class ImportExportRepository {
  Future<ImportResultEntity> importarAnimaisExcel(File arquivo);
  Future<String> exportarAnimaisExcel(List<AnimalEntity> animais, ExportOptionsEntity options);
  Future<String> exportarAnimaisViaAPI(ExportOptionsEntity options);
  Future<File> gerarTemplateImportacao();
  Future<bool> validarArquivoImportacao(File arquivo);
}
