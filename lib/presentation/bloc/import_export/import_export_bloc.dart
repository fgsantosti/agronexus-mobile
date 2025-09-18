import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/import_export_service.dart';
import 'package:agronexus/domain/models/import_result_entity.dart';
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

      // Determinar o tipo de resultado e personalizar a mensagem
      if (resultado.sucessos == 0 && resultado.duplicados > 0 && resultado.erros == 0) {
        // Caso 1: Apenas duplicados encontrados
        final mensagem = resultado.duplicados == 1 ? 'O animal já existe no sistema e foi ignorado.' : 'Todos os ${resultado.duplicados} animais já existem no sistema e foram ignorados.';

        final resultadoPersonalizado = resultado.copyWith(
          status: () => ImportStatus.sucesso,
        );

        emit(ImportacaoSucessoParcial(resultadoPersonalizado, mensagem));
      } else if (resultado.sucessos > 0 && resultado.duplicados > 0 && resultado.erros == 0) {
        // Caso 2: Sucessos + duplicados (sem erros)
        final mensagem = '${resultado.sucessos} ${resultado.sucessos == 1 ? 'animal importado' : 'animais importados'} '
            'com sucesso. ${resultado.duplicados} ${resultado.duplicados == 1 ? 'animal já existia' : 'animais já existiam'} '
            'e ${resultado.duplicados == 1 ? 'foi ignorado' : 'foram ignorados'}.';

        emit(ImportacaoSucessoParcial(resultado, mensagem));
      } else if (resultado.sucessos > 0 && resultado.erros > 0) {
        // Caso 3: Sucessos + erros (com ou sem duplicados)
        String mensagem = '${resultado.sucessos} ${resultado.sucessos == 1 ? 'animal importado' : 'animais importados'} com sucesso. ';
        mensagem += '${resultado.erros} ${resultado.erros == 1 ? 'erro encontrado' : 'erros encontrados'}.';

        if (resultado.duplicados > 0) {
          mensagem += ' ${resultado.duplicados} ${resultado.duplicados == 1 ? 'duplicado ignorado' : 'duplicados ignorados'}.';
        }

        emit(ImportacaoSucessoParcial(resultado, mensagem));
      } else if (resultado.sucessos == 0 && resultado.erros > 0) {
        // Caso 4: Apenas erros
        emit(ImportacaoSucesso(resultado)); // Usar o diálogo padrão que já mostra erros
      } else {
        // Caso padrão: sucesso completo
        emit(ImportacaoSucesso(resultado));
      }
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
