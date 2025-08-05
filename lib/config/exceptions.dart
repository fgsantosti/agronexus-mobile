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
                message = "Erro de validação nos dados fornecidos.";
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
    // Tratamento para erros de validação específicos
    if (responseData.containsKey('non_field_errors')) {
      final errors = responseData['non_field_errors'] as List;
      if (errors.isNotEmpty) {
        final firstError = errors.first.toString();

        // Tratamento específico para erro de unicidade
        if (firstError.contains('propriedade_id, identificacao_unica devem criar um set único')) {
          return 'Já existe um animal com esta identificação única nesta propriedade. Por favor, use uma identificação diferente.';
        }

        return firstError;
      }
    }

    // Tratamento para erros de campo específicos
    if (responseData.isNotEmpty) {
      final firstKey = responseData.keys.first;
      final firstValue = responseData[firstKey];

      if (firstValue is List && firstValue.isNotEmpty) {
        final errorMessage = firstValue.first.toString();

        // Traduzir nomes de campos para português
        String fieldName = _translateFieldName(firstKey);

        return '$fieldName: $errorMessage';
      }
    }

    return 'Erro de validação nos dados fornecidos.';
  }

  static String _translateFieldName(String fieldName) {
    switch (fieldName) {
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
