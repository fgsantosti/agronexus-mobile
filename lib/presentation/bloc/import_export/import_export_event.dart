import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/export_options_entity.dart';

abstract class ImportExportEvent extends Equatable {
  const ImportExportEvent();

  @override
  List<Object?> get props => [];
}

class ImportarAnimaisEvent extends ImportExportEvent {
  final File arquivo;

  const ImportarAnimaisEvent(this.arquivo);

  @override
  List<Object> get props => [arquivo];
}

class ExportarAnimaisEvent extends ImportExportEvent {
  final List<AnimalEntity> animais;
  final ExportOptionsEntity options;

  const ExportarAnimaisEvent(this.animais, this.options);

  @override
  List<Object> get props => [animais, options];
}

class ExportarAnimaisViaAPIEvent extends ImportExportEvent {
  final ExportOptionsEntity options;

  const ExportarAnimaisViaAPIEvent(this.options);

  @override
  List<Object> get props => [options];
}

class GerarTemplateEvent extends ImportExportEvent {
  const GerarTemplateEvent();
}

class ValidarArquivoEvent extends ImportExportEvent {
  final File arquivo;

  const ValidarArquivoEvent(this.arquivo);

  @override
  List<Object> get props => [arquivo];
}

class ResetImportExportEvent extends ImportExportEvent {
  const ResetImportExportEvent();
}
