import 'dart:convert';
import 'package:dio/dio.dart';

class AgroNexusException implements Exception {
  final String message;
  AgroNexusException({required this.message});

  static Future<AgroNexusException> fromDioError(dynamic e) async {
    String message = "An error occurred";
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.badCertificate:
          message = "Bad certificate";
          break;
        case DioExceptionType.badResponse:
          if (e.response?.data != null) {
            try {
              dynamic responseData = e.response?.data;

              // Tentar converter string JSON para Map se necessário
              if (responseData is String) {
                responseData = json.decode(responseData);
              }

              if (responseData is Map<String, dynamic>) {
                // Verificar se há campo 'detail' (comum em erros de autenticação)
                if (responseData.containsKey('detail')) {
                  message = responseData['detail'].toString();
                  break;
                }

                // Verificar se há campo 'error' genérico
                if (responseData.containsKey('error')) {
                  message = responseData['error'].toString();
                  break;
                }

                // Tratamento específico para erros de validação (400)
                if (e.response?.statusCode == 400) {
                  message = _parseValidationError(responseData);
                  break;
                }

                // Se chegou aqui, tenta extrair a primeira mensagem disponível
                if (responseData.isNotEmpty) {
                  final firstKey = responseData.keys.first;
                  final firstValue = responseData[firstKey];
                  if (firstValue is List && firstValue.isNotEmpty) {
                    message = firstValue.first.toString();
                  } else if (firstValue is String) {
                    message = firstValue;
                  } else {
                    message = _getMessageForStatusCode(e.response?.statusCode);
                  }
                } else {
                  message = _getMessageForStatusCode(e.response?.statusCode);
                }
              } else {
                // Se não é um Map, usa a resposta como string
                message = responseData.toString();
              }
            } catch (parseError) {
              print("⚠️ Erro ao processar resposta da API: $parseError");
              message = "Erro ao processar resposta da API";
            }
          } else {
            // Se não há dados na resposta, usa mensagem genérica baseada no código
            message = _getMessageForStatusCode(e.response?.statusCode);
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

      // Log apenas em caso de erro inesperado
      final statusCode = e.response?.statusCode;
      if (e.response == null || (statusCode != null && statusCode >= 500)) {
        print("🔴 AgroNexusException: $message");
        print("🔴 Request URL: ${e.requestOptions.uri}");
        print("🔴 Request Method: ${e.requestOptions.method}");
        if (statusCode != null) {
          print("🔴 Response Status: $statusCode");
        }
      }
    }

    return AgroNexusException(message: message);
  }

  static String _parseValidationError(Map<String, dynamic> responseData) {
    // Tratamento específico para erro de senha do Django
    if (responseData.containsKey('error') && responseData.containsKey('details')) {
      final error = responseData['error'].toString();
      final details = responseData['details'];

      // Verificar se é erro de usuário duplicado para não adicionar prefixo
      if (error.toLowerCase().contains('nome de usuário já existe') || (error.toLowerCase().contains('username') && error.toLowerCase().contains('already exists'))) {
        return 'Nome de usuário já existe';
      }

      if (error.toLowerCase().contains('e-mail já cadastrado') || (error.toLowerCase().contains('email') && error.toLowerCase().contains('already exists'))) {
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

        // Tratamento específico para erros de usuário duplicado
        if (firstKey == 'username' && errorMessage.toLowerCase().contains('already exists')) {
          return 'Nome de usuário já existe';
        }

        if (firstKey == 'email' && errorMessage.toLowerCase().contains('already exists')) {
          return 'E-mail já cadastrado';
        }

        // Traduzir nomes de campos para português
        String fieldName = _translateFieldName(firstKey);
        return '$fieldName: $errorMessage';
      } else if (firstValue is String && firstValue.isNotEmpty) {
        // Tratamento para quando o valor é uma string direta
        if (firstKey == 'username' && firstValue.toLowerCase().contains('already exists')) {
          return 'Nome de usuário já existe';
        }

        if (firstKey == 'email' && firstValue.toLowerCase().contains('already exists')) {
          return 'E-mail já cadastrado';
        }

        String fieldName = _translateFieldName(firstKey);
        return '$fieldName: $firstValue';
      }
    }

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

  static String _getMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requisição inválida';
      case 401:
        return 'Não autorizado - verifique suas credenciais';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Recurso não encontrado';
      case 500:
        return 'Erro interno do servidor';
      case 502:
        return 'Servidor temporariamente indisponível';
      case 503:
        return 'Serviço indisponível';
      default:
        return 'Erro: $statusCode';
    }
  }
}
