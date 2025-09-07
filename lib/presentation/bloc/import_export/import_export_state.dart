import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/import_result_entity.dart';

abstract class ImportExportState extends Equatable {
  const ImportExportState();

  @override
  List<Object?> get props => [];
}

class ImportExportInitial extends ImportExportState {}

class ImportExportLoading extends ImportExportState {}

class ImportacaoSucesso extends ImportExportState {
  final ImportResultEntity resultado;

  const ImportacaoSucesso(this.resultado);

  @override
  List<Object> get props => [resultado];
}

class ExportacaoSucesso extends ImportExportState {
  final String caminhoArquivo;

  const ExportacaoSucesso(this.caminhoArquivo);

  @override
  List<Object> get props => [caminhoArquivo];
}

class TemplateSucesso extends ImportExportState {
  final File templateFile;

  const TemplateSucesso(this.templateFile);

  @override
  List<Object> get props => [templateFile];
}

class ValidacaoSucesso extends ImportExportState {
  final bool arquivoValido;

  const ValidacaoSucesso(this.arquivoValido);

  @override
  List<Object> get props => [arquivoValido];
}

class ImportExportError extends ImportExportState {
  final String message;

  const ImportExportError(this.message);

  @override
  List<Object> get props => [message];
}
