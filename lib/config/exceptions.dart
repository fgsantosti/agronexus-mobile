import 'dart:convert';
import 'package:dio/dio.dart';

class AgroNexusException implements Exception {
  final String message;
  AgroNexusException({required this.message});

  static Future<AgroNexusException> fromDioError(dynamic e) async {
    String message = "An error occurred";
    if (e is DioException) {
      // Adiciona informações detalhadas do erro
      String detailedMessage = "";

      switch (e.type) {
        case DioExceptionType.badCertificate:
          message = "Bad certificate";
          break;
        case DioExceptionType.badResponse:
          print("🔍 Debug - Status Code: ${e.response?.statusCode}");
          print("🔍 Debug - Response Data Type: ${e.response?.data.runtimeType}");
          print("🔍 Debug - Response Data: ${e.response?.data}");

          message = "Bad response: ${e.response?.statusCode}";
          if (e.response?.data != null) {
            detailedMessage = " - ${e.response?.data.toString()}";

            // Tratamento específico para erros de validação
            if (e.response?.statusCode == 400) {
              try {
                dynamic responseData = e.response?.data;

                // Tentar converter string JSON para Map se necessário
                if (responseData is String) {
                  print("🔍 Debug - Tentando fazer parse de JSON string");
                  responseData = json.decode(responseData);
                }

                if (responseData is Map<String, dynamic>) {
                  print("🔍 Debug - Usando _parseValidationError");
                  message = _parseValidationError(responseData);
                } else {
                  print("🔍 Debug - responseData não é Map: ${responseData.runtimeType}");
                }
              } catch (parseError) {
                print("🔍 Debug - Erro ao fazer parse: $parseError");
                message = "Dados fornecidos são inválidos.";
              }
            }
          }
          break;
        case DioExceptionType.cancel:
          message = "Request to server was cancelled";
          break;
        case DioExceptionType.connectionError:
          message = "Connection error: ${e.message}";
          break;
        case DioExceptionType.connectionTimeout:
          message = "Connection timeout";
          break;
        case DioExceptionType.receiveTimeout:
          message = "Receive timeout";
          break;
        case DioExceptionType.sendTimeout:
          message = "Send timeout";
          break;
        case DioExceptionType.unknown:
          message = "Unknown error: ${e.message}";
          break;
      }

      if (e.response?.statusCode != 400) {
        message += detailedMessage;
      }

      // Log detalhado para debug
      print("🔴 AgroNexusException: $message");
      print("🔴 Request URL: ${e.requestOptions.uri}");
      print("🔴 Request Method: ${e.requestOptions.method}");
      print("🔴 Request Data: ${e.requestOptions.data}");
      if (e.response != null) {
        print("🔴 Response Status: ${e.response?.statusCode}");
        print("🔴 Response Data: ${e.response?.data}");
      }
    }
    // await FirebaseCrashlytics.instance.recordFlutterError(
    //   FlutterErrorDetails(exception: e),
    // );
    return AgroNexusException(message: message);
  }

  static String _parseValidationError(Map<String, dynamic> responseData) {
    print("🔍 DEBUG _parseValidationError - responseData keys: ${responseData.keys}");
    print("🔍 DEBUG _parseValidationError - responseData: $responseData");

    // Tratamento específico para erro de senha do Django
    if (responseData.containsKey('error') && responseData.containsKey('details')) {
      print("🔍 DEBUG - Usando tratamento de erro de senha");
      final error = responseData['error'].toString();
      final details = responseData['details'];

      // Verificar se é erro de usuário duplicado para não adicionar prefixo
      if (error.toLowerCase().contains('nome de usuário já existe') || error.toLowerCase().contains('username') && error.toLowerCase().contains('already exists')) {
        return 'Nome de usuário já existe';
      }

      if (error.toLowerCase().contains('e-mail já cadastrado') || error.toLowerCase().contains('email') && error.toLowerCase().contains('already exists')) {
        return 'E-mail já cadastrado';
      }

      if (details is List && details.isNotEmpty) {
        String detailsText = details.join(' ');
        return '$error: $detailsText';
      }

      return error;
    }

    // Tratamento para erros de validação específicos
    if (responseData.containsKey('non_field_errors')) {
      print("🔍 DEBUG - Usando tratamento de non_field_errors");
      final errors = responseData['non_field_errors'] as List;
      if (errors.isNotEmpty) {
        final firstError = errors.first.toString();
        print("🔍 DEBUG - non_field_errors primeiro erro: $firstError");

        // Tratamento específico para erro de unicidade
        if (firstError.contains('propriedade_id, identificacao_unica devem criar um set único')) {
          return 'Já existe um animal com esta identificação única nesta propriedade. Por favor, use uma identificação diferente.';
        }

        return firstError;
      }
    }

    // Tratamento para erros de campo específicos
    if (responseData.isNotEmpty) {
      print("🔍 DEBUG - Usando tratamento de campo específico");
      final firstKey = responseData.keys.first;
      final firstValue = responseData[firstKey];
      print("🔍 DEBUG - Campo: $firstKey, Valor: $firstValue, Tipo: ${firstValue.runtimeType}");

      if (firstValue is List && firstValue.isNotEmpty) {
        final errorMessage = firstValue.first.toString();
        print("🔍 DEBUG - Mensagem de erro: $errorMessage");

        // Tratamento específico para erros de usuário duplicado
        if (firstKey == 'username' && errorMessage.toLowerCase().contains('already exists')) {
          print("🔍 DEBUG - Detectado erro de username duplicado");
          return 'Nome de usuário já existe';
        }

        if (firstKey == 'email' && errorMessage.toLowerCase().contains('already exists')) {
          print("🔍 DEBUG - Detectado erro de email duplicado");
          return 'E-mail já cadastrado';
        }

        // Traduzir nomes de campos para português
        String fieldName = _translateFieldName(firstKey);
        print("🔍 DEBUG - Campo traduzido: $fieldName");

        return '$fieldName: $errorMessage';
      } else if (firstValue is String && firstValue.isNotEmpty) {
        print("🔍 DEBUG - Valor é string: $firstValue");

        // Tratamento para quando o valor é uma string direta
        if (firstKey == 'username' && firstValue.toLowerCase().contains('already exists')) {
          print("🔍 DEBUG - Detectado erro de username duplicado (string)");
          return 'Nome de usuário já existe';
        }

        if (firstKey == 'email' && firstValue.toLowerCase().contains('already exists')) {
          print("🔍 DEBUG - Detectado erro de email duplicado (string)");
          return 'E-mail já cadastrado';
        }

        String fieldName = _translateFieldName(firstKey);
        return '$fieldName: $firstValue';
      }
    }

    print("🔍 DEBUG - Retornando mensagem padrão");
    return 'Dados fornecidos são inválidos.';
  }

  static String _translateFieldName(String fieldName) {
    switch (fieldName) {
      // Campos de usuário
      case 'username':
        return 'Nome de usuário';
      case 'email':
        return 'E-mail';
      case 'first_name':
        return 'Nome';
      case 'last_name':
        return 'Sobrenome';
      case 'password':
      case 'password1':
      case 'password2':
        return 'Senha';
      // Campos de animais
      case 'identificacao_unica':
        return 'Identificação única';
      case 'nome_registro':
        return 'Nome do registro';
      case 'sexo':
        return 'Sexo';
      case 'data_nascimento':
        return 'Data de nascimento';
      case 'categoria':
        return 'Categoria';
      case 'status':
        return 'Status';
      case 'propriedade_id':
        return 'Propriedade';
      case 'especie_id':
        return 'Espécie';
      case 'raca_id':
        return 'Raça';
      case 'lote_atual_id':
        return 'Lote atual';
      case 'data_compra':
        return 'Data de compra';
      case 'valor_compra':
        return 'Valor de compra';
      case 'origem':
        return 'Origem';
      case 'data_venda':
        return 'Data de venda';
      case 'valor_venda':
        return 'Valor de venda';
      case 'destino':
        return 'Destino';
      case 'data_morte':
        return 'Data de morte';
      case 'causa_morte':
        return 'Causa da morte';
      case 'observacoes':
        return 'Observações';
      default:
        return fieldName;
    }
  }
}
