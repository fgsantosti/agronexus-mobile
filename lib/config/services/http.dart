import 'package:dio/dio.dart';

abstract class HttpService {
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  });
  Future<Response> post({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  });
  Future<Response> put({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  });
  Future<Response> patch({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  });
  Future<Response> delete({
    required String path,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  });
}
