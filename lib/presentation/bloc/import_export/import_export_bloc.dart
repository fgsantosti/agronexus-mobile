import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/import_export_service.dart';
import 'import_export_event.dart';
import 'import_export_state.dart';

class ImportExportBloc extends Bloc<ImportExportEvent, ImportExportState> {
  final ImportExportService _service;

  ImportExportBloc(this._service) : super(ImportExportInitial()) {
    on<ImportarAnimaisEvent>(_onImportarAnimais);
    on<ExportarAnimaisEvent>(_onExportarAnimais);
    on<ExportarAnimaisViaAPIEvent>(_onExportarAnimaisViaAPI);
    on<GerarTemplateEvent>(_onGerarTemplate);
    on<ValidarArquivoEvent>(_onValidarArquivo);
    on<ResetImportExportEvent>(_onReset);
  }

  Future<void> _onImportarAnimais(ImportarAnimaisEvent event, Emitter<ImportExportState> emit) async {
    emit(ImportExportLoading());
    try {
      final resultado = await _service.importarAnimaisExcel(event.arquivo);
      emit(ImportacaoSucesso(resultado));
    } catch (e) {
      emit(ImportExportError(e.toString()));
    }
  }

  Future<void> _onExportarAnimais(ExportarAnimaisEvent event, Emitter<ImportExportState> emit) async {
    emit(ImportExportLoading());
    try {
      final caminhoArquivo = await _service.exportarAnimaisExcel(event.animais, event.options);
      emit(ExportacaoSucesso(caminhoArquivo));
    } catch (e) {
      emit(ImportExportError(e.toString()));
    }
  }

  Future<void> _onExportarAnimaisViaAPI(ExportarAnimaisViaAPIEvent event, Emitter<ImportExportState> emit) async {
    emit(ImportExportLoading());
    try {
      final caminhoArquivo = await _service.exportarAnimaisViaAPI(event.options);
      emit(ExportacaoSucesso(caminhoArquivo));
    } catch (e) {
      emit(ImportExportError(e.toString()));
    }
  }

  Future<void> _onGerarTemplate(GerarTemplateEvent event, Emitter<ImportExportState> emit) async {
    emit(ImportExportLoading());
    try {
      final template = await _service.gerarTemplateImportacao();
      emit(TemplateSucesso(template));
    } catch (e) {
      emit(ImportExportError(e.toString()));
    }
  }

  Future<void> _onValidarArquivo(ValidarArquivoEvent event, Emitter<ImportExportState> emit) async {
    emit(ImportExportLoading());
    try {
      final valido = await _service.validarArquivoImportacao(event.arquivo);
      emit(ValidacaoSucesso(valido));
    } catch (e) {
      emit(ImportExportError(e.toString()));
    }
  }

  Future<void> _onReset(ResetImportExportEvent event, Emitter<ImportExportState> emit) async {
    emit(ImportExportInitial());
  }
}
