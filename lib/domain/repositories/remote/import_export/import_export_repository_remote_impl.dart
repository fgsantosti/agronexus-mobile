import 'dart:io';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/import_result_entity.dart';
import 'package:agronexus/domain/models/export_options_entity.dart';
import 'package:agronexus/domain/repositories/remote/import_export/import_export_remote_repository.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:agronexus/config/api.dart';
import 'package:dio/dio.dart';
import 'package:agronexus/config/inject_dependencies.dart';
import 'package:agronexus/domain/services/auth_service.dart';

class ImportExportRepositoryImpl implements ImportExportRepository {
  final HttpService httpService;

  ImportExportRepositoryImpl({required this.httpService});

  @override
  Future<ImportResultEntity> importarAnimaisExcel(File arquivo) async {
    try {
      // Usar FormData para enviar o arquivo
      final formData = FormData();

      // Adicionar o arquivo ao FormData
      final fileName = arquivo.path.split('/').last;
      formData.files.add(MapEntry(
        'arquivo',
        await MultipartFile.fromFile(
          arquivo.path,
          filename: fileName,
        ),
      ));

      // Enviar arquivo para a API
      final response = await httpService.post(
        path: '${API.animais}importar_planilha/',
        data: formData,
        isAuth: true,
        headers: {'Content-Type': 'multipart/form-data'},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        // Mapear resposta da API para ImportResultEntity
        ImportStatus status;
        switch (data['status']) {
          case 'sucesso':
            status = ImportStatus.sucesso;
            break;
          case 'parcial':
            status = ImportStatus.processando;
            break;
          case 'erro':
          default:
            status = ImportStatus.erro;
            break;
        }

        return ImportResultEntity(
          totalRegistros: data['total_registros'] ?? 0,
          sucessos: data['sucessos'] ?? 0,
          erros: data['erros'] ?? 0,
          duplicados: data['duplicados'] ?? 0,
          mensagensErro: List<String>.from(data['mensagens_erro'] ?? []),
          status: status,
        );
      } else {
        throw Exception('Erro na resposta da API: ${response.statusCode}');
      }
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<String> exportarAnimaisExcel(List<AnimalEntity> animais, ExportOptionsEntity options) async {
    try {
      // Preparar dados para envio à API
      final propriedadeId = animais.isNotEmpty ? animais.first.propriedade?.id : null;

      final requestData = {
        'propriedade_id': propriedadeId,
        'incluir_genealogia': options.selectedFields.contains('pai') || options.selectedFields.contains('mae'),
        'incluir_estatisticas': options.includeInactives,
        'formato_data': 'dd/MM/yyyy',
        'ids_animais': animais.map((a) => a.id).toList(),
      };

      // Obter token de autenticação
      final authService = getIt<AuthService>();
      final token = await authService.token;

      if (token.isEmpty) {
        throw Exception('Token de autenticação não encontrado');
      }

      // Usar diretamente o Dio com responseType bytes para arquivo binário
      final dio = Dio();
      final response = await dio.post(
        '${API.baseUrl}${API.animais}exportar_excel/',
        data: requestData,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Salvar o arquivo recebido
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'animais_export_$timestamp.xlsx';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.data);

        print('=== EXPORT DEBUG: Arquivo salvo em: $filePath');
        return filePath;
      } else {
        throw Exception('Erro ao exportar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<String> exportarAnimaisViaAPI(ExportOptionsEntity options) async {
    try {
      // Preparar dados para envio à API
      final requestData = {
        'propriedade_id': options.propriedadeId,
        'incluir_genealogia': options.selectedFields.contains('pai') || options.selectedFields.contains('mae'),
        'incluir_estatisticas': options.includeInactives,
        'formato_data': 'dd/MM/yyyy',
        'especie_id': options.especieId,
        'status': options.includeInactives ? null : 'ativo',
      };

      // Obter token de autenticação
      final authService = getIt<AuthService>();
      final token = await authService.token;

      if (token.isEmpty) {
        throw Exception('Token de autenticação não encontrado');
      }

      // Usar diretamente o Dio com responseType bytes para arquivo binário
      final dio = Dio();
      final response = await dio.post(
        '${API.baseUrl}${API.animais}exportar_excel/',
        data: requestData,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Salvar o arquivo recebido
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'animais_export_$timestamp.xlsx';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.data);

        print('=== EXPORT DEBUG: Arquivo salvo em: $filePath');
        return filePath;
      } else {
        throw Exception('Erro ao exportar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<File> gerarTemplateImportacao() async {
    try {
      // Chamar a API para obter o template
      final response = await httpService.get(
        path: '${API.animais}template_importacao/',
        isAuth: true,
      );

      if (response.statusCode == 200) {
        // Salvar o arquivo recebido
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/template_importacao_animais.xlsx';

        final file = File(filePath);
        await file.writeAsBytes(response.data);
        return file;
      } else {
        throw Exception('Erro ao gerar template');
      }
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<bool> validarArquivoImportacao(File arquivo) async {
    try {
      // Validações básicas no cliente
      final bytes = await arquivo.readAsBytes();

      // Verificar se é um arquivo Excel válido
      try {
        final excel = Excel.decodeBytes(bytes);

        // Verificar se tem pelo menos uma planilha
        if (excel.tables.isEmpty) return false;

        final sheet = excel.tables.values.first;
        if (sheet.rows.isEmpty) return false;

        // Verificar cabeçalhos mínimos
        final headers = sheet.rows.first.map((cell) => cell?.value?.toString() ?? '').toList();
        final headerObrigatorios = ['identificacao', 'especie', 'sexo', 'data_nascimento'];

        for (String header in headerObrigatorios) {
          if (!headers.contains(header)) {
            return false;
          }
        }

        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
