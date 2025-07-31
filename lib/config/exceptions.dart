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
          message = "Bad response: ${e.response?.statusCode}";
          if (e.response?.data != null) {
            detailedMessage = " - ${e.response?.data.toString()}";
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
      
      message += detailedMessage;
      
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
}
