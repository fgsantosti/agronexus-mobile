import 'dart:io';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/import_result_entity.dart';
import 'package:agronexus/domain/models/export_options_entity.dart';
import 'package:agronexus/domain/repositories/remote/import_export/import_export_remote_repository.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:agronexus/config/api.dart';
import 'package:dio/dio.dart';
import 'package:agronexus/config/inject_dependencies.dart';
import 'package:agronexus/domain/services/auth_service.dart';

class ImportExportRepositoryImpl implements ImportExportRepository {
  final HttpService httpService;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  ImportExportRepositoryImpl({required this.httpService});

  @override
  Future<ImportResultEntity> importarAnimaisExcel(File arquivo) async {
    try {
      // Ler o arquivo Excel
      final bytes = await arquivo.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final animaisParaImportar = <Map<String, dynamic>>[];
      final erros = <String>[];

      // Assumir que a primeira planilha contém os dados
      final sheet = excel.tables.values.first;
      if (sheet.rows.isEmpty) {
        throw Exception('Arquivo Excel vazio ou inválido');
      }

      // Primeira linha deve ser o cabeçalho
      final headers = sheet.rows.first.map((cell) => cell?.value?.toString() ?? '').toList();

      // Validar cabeçalhos obrigatórios
      final headerObrigatorios = ['identificacao', 'especie', 'sexo', 'data_nascimento', 'categoria', 'status'];

      for (String header in headerObrigatorios) {
        if (!headers.contains(header)) {
          erros.add('Coluna obrigatória "$header" não encontrada');
        }
      }

      if (erros.isNotEmpty) {
        return ImportResultEntity(
          totalRegistros: 0,
          sucessos: 0,
          erros: erros.length,
          mensagensErro: erros,
          status: ImportStatus.erro,
        );
      }

      // Processar linhas de dados (ignorar cabeçalho)
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        final animalData = <String, dynamic>{};

        for (int j = 0; j < headers.length && j < row.length; j++) {
          final cellValue = row[j]?.value?.toString() ?? '';
          animalData[headers[j]] = cellValue;
        }

        // Validar dados do animal
        final validacaoErros = _validarDadosAnimal(animalData, i + 1);
        if (validacaoErros.isEmpty) {
          animaisParaImportar.add(_processarDadosAnimal(animalData));
        } else {
          erros.addAll(validacaoErros);
        }
      }

      // Se houver animais válidos para importar, enviar para API
      int sucessos = 0;
      if (animaisParaImportar.isNotEmpty) {
        try {
          // Enviar em lotes para não sobrecarregar a API
          const tamanhoBatch = 50;
          for (int i = 0; i < animaisParaImportar.length; i += tamanhoBatch) {
            final batch = animaisParaImportar.skip(i).take(tamanhoBatch).toList();

            final response = await httpService.post(
              path: '${API.animais}import-batch/',
              data: {'animais': batch},
              isAuth: true,
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              sucessos += batch.length;
            }
          }
        } catch (e) {
          erros.add('Erro ao importar dados: ${e.toString()}');
        }
      }

      return ImportResultEntity(
        totalRegistros: sheet.rows.length - 1, // Excluir cabeçalho
        sucessos: sucessos,
        erros: erros.length,
        mensagensErro: erros,
        status: erros.isEmpty ? ImportStatus.sucesso : (sucessos > 0 ? ImportStatus.processando : ImportStatus.erro),
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<String> exportarAnimaisExcel(List<AnimalEntity> animais, ExportOptionsEntity options) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Animais'];

      // Definir cabeçalhos
      final headers = [
        'Identificação',
        'Nome',
        'Espécie',
        'Raça',
        'Sexo',
        'Data Nascimento',
        'Idade',
        'Categoria',
        'Status',
        'Peso Atual (kg)',
        'Lote Atual',
        'Propriedade',
      ];

      if (options.selectedFields.contains('pai') || options.selectedFields.contains('mae')) {
        headers.addAll(['Pai', 'Mãe']);
      }

      headers.add('Observações');

      // Adicionar cabeçalhos
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(bold: true);
      }

      // Adicionar dados dos animais
      for (int i = 0; i < animais.length; i++) {
        final animal = animais[i];
        final rowIndex = i + 1;

        final dados = [
          animal.identificacaoUnica,
          animal.nomeRegistro ?? '',
          animal.especie?.nomeDisplay ?? '',
          animal.raca?.nome ?? '',
          animal.sexo.label,
          animal.dataNascimento.isNotEmpty ? _formatarData(animal.dataNascimento) : '',
          animal.dataNascimento.isNotEmpty ? _calcularIdade(animal.dataNascimento) : '',
          animal.categoria.label,
          animal.status.label,
          '', // peso atual não está disponível na entidade atual
          animal.loteAtual?.nome ?? '',
          animal.propriedade?.nome ?? '',
        ];

        if (options.selectedFields.contains('pai') || options.selectedFields.contains('mae')) {
          dados.addAll([
            animal.pai?.identificacaoUnica ?? '',
            animal.mae?.identificacaoUnica ?? '',
          ]);
        }

        dados.add(animal.observacoes ?? '');

        for (int j = 0; j < dados.length; j++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
          cell.value = TextCellValue(dados[j]);
        }
      }

      // Adicionar estatísticas se solicitado
      if (options.includeInactives) {
        final estatisticasSheet = excel['Estatísticas'];
        _adicionarEstatisticas(estatisticasSheet, animais);
      }

      // Salvar arquivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/animais_export_$timestamp.xlsx';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        return filePath;
      } else {
        throw Exception('Erro ao gerar arquivo Excel');
      }
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<File> gerarTemplateImportacao() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Template'];

      // Cabeçalhos do template
      final headers = ['identificacao', 'nome', 'especie', 'raca', 'sexo', 'data_nascimento', 'categoria', 'status', 'peso_atual', 'propriedade_id', 'lote_id', 'pai_id', 'mae_id', 'observacoes'];

      // Adicionar cabeçalhos
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(bold: true);
      }

      // Adicionar linha de exemplo
      final exemplo = ['BOV001', 'Animal Exemplo', 'bovino', 'Nelore', 'F', '15/03/2023', 'novilha', 'ativo', '380', '1', '1', '', '', 'Animal de exemplo para importação'];

      for (int i = 0; i < exemplo.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
        cell.value = TextCellValue(exemplo[i]);
      }

      // Adicionar instruções em uma nova planilha
      final instrucoes = excel['Instruções'];
      _adicionarInstrucoes(instrucoes);

      // Salvar template
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/template_importacao_animais.xlsx';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
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
      final bytes = await arquivo.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Verificar se tem pelo menos uma planilha
      if (excel.tables.isEmpty) return false;

      final sheet = excel.tables.values.first;
      if (sheet.rows.isEmpty) return false;

      // Verificar cabeçalhos mínimos
      final headers = sheet.rows.first.map((cell) => cell?.value?.toString() ?? '').toList();
      final headerObrigatorios = ['identificacao', 'especie', 'sexo', 'data_nascimento'];

      return headerObrigatorios.every((header) => headers.contains(header));
    } catch (e) {
      return false;
    }
  }

  // Métodos auxiliares
  List<String> _validarDadosAnimal(Map<String, dynamic> dados, int linha) {
    final erros = <String>[];

    // Validações obrigatórias
    if (dados['identificacao']?.toString().isEmpty ?? true) {
      erros.add('Linha $linha: Identificação é obrigatória');
    }

    if (dados['especie']?.toString().isEmpty ?? true) {
      erros.add('Linha $linha: Espécie é obrigatória');
    }

    if (dados['sexo']?.toString().isEmpty ?? true) {
      erros.add('Linha $linha: Sexo é obrigatório');
    }

    if (dados['data_nascimento']?.toString().isEmpty ?? true) {
      erros.add('Linha $linha: Data de nascimento é obrigatória');
    } else {
      // Validar formato da data
      try {
        _dateFormat.parseStrict(dados['data_nascimento'].toString());
      } catch (e) {
        erros.add('Linha $linha: Data de nascimento inválida (use formato dd/MM/yyyy)');
      }
    }

    return erros;
  }

  Map<String, dynamic> _processarDadosAnimal(Map<String, dynamic> dados) {
    return {
      'identificacao_unica': dados['identificacao'],
      'nome_registro': dados['nome'] ?? '',
      'especie': dados['especie'],
      'raca': dados['raca'] ?? '',
      'sexo': dados['sexo']?.toString().toUpperCase() == 'M' || dados['sexo']?.toString().toLowerCase() == 'macho' ? 'M' : 'F',
      'data_nascimento': _converterDataParaISO(dados['data_nascimento']),
      'categoria': dados['categoria'] ?? '',
      'status': dados['status'] ?? 'ativo',
      'peso_atual': dados['peso_atual'] != null ? double.tryParse(dados['peso_atual'].toString()) : null,
      'propriedade_id': dados['propriedade_id'],
      'lote_id': dados['lote_id'],
      'pai_id': dados['pai_id'],
      'mae_id': dados['mae_id'],
      'observacoes': dados['observacoes'] ?? '',
    };
  }

  String _formatarData(String dataISO) {
    try {
      final date = DateTime.parse(dataISO);
      return _dateFormat.format(date);
    } catch (e) {
      return dataISO;
    }
  }

  String _converterDataParaISO(String dataBR) {
    try {
      final date = _dateFormat.parseStrict(dataBR);
      return date.toIso8601String().split('T')[0];
    } catch (e) {
      return dataBR;
    }
  }

  String _calcularIdade(String dataNascimento) {
    try {
      final nascimento = DateTime.parse(dataNascimento);
      final agora = DateTime.now();
      final diferenca = agora.difference(nascimento);
      final anos = (diferenca.inDays / 365).floor();
      final meses = ((diferenca.inDays % 365) / 30).floor();

      if (anos > 0) {
        return '$anos anos';
      } else if (meses > 0) {
        return '$meses meses';
      } else {
        return '${diferenca.inDays} dias';
      }
    } catch (e) {
      return '';
    }
  }

  void _adicionarEstatisticas(Sheet sheet, List<AnimalEntity> animais) {
    final estatisticas = [
      ['Métrica', 'Valor'],
      ['Total de Animais', animais.length.toString()],
      ['Machos', animais.where((a) => a.sexo == Sexo.macho).length.toString()],
      ['Fêmeas', animais.where((a) => a.sexo == Sexo.femea).length.toString()],
      ['Ativos', animais.where((a) => a.status == StatusAnimal.ativo).length.toString()],
      ['Peso Médio (kg)', _calcularPesoMedio(animais)],
      ['Peso Total (kg)', _calcularPesoTotal(animais)],
    ];

    for (int i = 0; i < estatisticas.length; i++) {
      for (int j = 0; j < estatisticas[i].length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i));
        cell.value = TextCellValue(estatisticas[i][j]);

        if (i == 0) {
          cell.cellStyle = CellStyle(bold: true);
        }
      }
    }
  }

  void _adicionarInstrucoes(Sheet sheet) {
    final instrucoes = [
      'INSTRUÇÕES PARA IMPORTAÇÃO DE ANIMAIS',
      '',
      '1. Preencha todas as colunas obrigatórias (marcadas em azul)',
      '2. Use o formato dd/MM/yyyy para datas',
      '3. Para sexo, use: M (Macho) ou F (Fêmea)',
      '4. Para status, use: ativo, inativo, vendido, morto',
      '5. Para peso, use apenas números (sem vírgulas)',
      '6. Máximo de 1000 animais por importação',
      '',
      'CAMPOS OBRIGATÓRIOS:',
      '• identificacao: Código único do animal',
      '• especie: bovino, caprino, ovino, equino, suino',
      '• sexo: M ou F',
      '• data_nascimento: dd/MM/yyyy',
      '',
      'CAMPOS OPCIONAIS:',
      '• nome: Nome do animal',
      '• raca: Raça do animal',
      '• categoria: Categoria conforme a espécie',
      '• peso_atual: Peso em kg',
      '• propriedade_id: ID da propriedade',
      '• lote_id: ID do lote',
      '• pai_id: ID do pai (se existir)',
      '• mae_id: ID da mãe (se existir)',
      '• observacoes: Informações adicionais',
    ];

    for (int i = 0; i < instrucoes.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      cell.value = TextCellValue(instrucoes[i]);

      if (i == 0) {
        cell.cellStyle = CellStyle(bold: true, fontSize: 14);
      }
    }
  }

  String _calcularPesoMedio(List<AnimalEntity> animais) {
    // Como não temos campo peso na entidade atual, retornamos 0
    return '0';
  }

  String _calcularPesoTotal(List<AnimalEntity> animais) {
    // Como não temos campo peso na entidade atual, retornamos 0
    return '0';
  }

  @override
  Future<String> exportarAnimaisViaAPI(ExportOptionsEntity options) async {
    try {
      // Preparar dados para envio à API
      Map<String, dynamic> requestData = {
        'incluir_genealogia': options.incluirGenealogia,
        'incluir_estatisticas': options.incluirEstatisticas,
        'formato_data': options.formatoData,
      };

      // Adicionar filtros se especificados
      if (options.propriedadeId != null && options.propriedadeId!.isNotEmpty) {
        requestData['propriedade_id'] = options.propriedadeId;
      }

      if (options.especieId != null && options.especieId!.isNotEmpty) {
        requestData['especie_id'] = options.especieId;
      }

      if (options.status != null && options.status!.isNotEmpty) {
        requestData['status'] = options.status;
      }

      if (options.search != null && options.search!.isNotEmpty) {
        requestData['search'] = options.search;
      }

      print('=== EXPORT DEBUG: Chamando API com dados: $requestData');

      // Obter token de autenticação
      final token = await getIt<AuthService>().token;

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
        throw AgroNexusException(message: 'Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      print('=== EXPORT DEBUG: Erro ao exportar via API: $e');
      throw await AgroNexusException.fromDioError(e);
    }
  }
}
