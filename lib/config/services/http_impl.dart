import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/inject_dependencies.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/domain/services/auth_service.dart';
import 'package:agronexus/domain/services/user_service.dart';
import 'package:dio/dio.dart';

class HttpServiceImpl implements HttpService {
  late Dio _dio;

  HttpServiceImpl() {
    _dio = Dio(
      BaseOptions(baseUrl: API.baseUrl),
    );
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<Map<String, dynamic>> _getAuth(Map<String, dynamic>? oldHeaders, bool isAuth) async {
    final Map<String, dynamic> headers = oldHeaders ?? {};
    if (isAuth) {
      String token = await getIt<AuthService>().token;
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<void> _relogin(Exception e) async {
    UserEntity user = await getIt<UserService>().getSelfLocalUser();
    if (user.password == null) throw e;

    await getIt<AuthService>().login(
      email: user.email,
      password: user.password!,
    );
  }

  @override
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
    ResponseType? responseType,
  }) async {
    try {
      Map<String, dynamic> newHeaders = await _getAuth(headers, isAuth);
      final Options options = Options(
        headers: newHeaders,
        responseType: responseType,
      );
      return _dio.get(path, queryParameters: queryParameters, options: options);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401 && withRelogin) {
          await _relogin(e);
          return await get(
            path: path,
            queryParameters: queryParameters,
            headers: headers,
            isAuth: isAuth,
            withRelogin: false,
            responseType: responseType,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<Response> post({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  }) async {
    try {
      Map<String, dynamic> nHeaders = await _getAuth(headers, isAuth);
      final Options options = Options(headers: nHeaders);
      return await _dio.post(path, data: data, options: options);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401 && withRelogin) {
          await _relogin(e);
          return await post(
            path: path,
            data: data,
            headers: headers,
            isAuth: isAuth,
            withRelogin: false,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<Response> put({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  }) async {
    try {
      Map<String, dynamic> nHeaders = await _getAuth(headers, isAuth);
      final Options options = Options(headers: nHeaders);
      return await _dio.put(path, data: data, options: options);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401 && withRelogin) {
          await _relogin(e);
          return await put(
            path: path,
            data: data,
            headers: headers,
            isAuth: isAuth,
            withRelogin: false,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<Response> delete({
    required String path,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  }) async {
    try {
      Map<String, dynamic> newHeaders = await _getAuth(headers, isAuth);
      final Options options = Options(headers: newHeaders);
      return await _dio.delete(path, options: options);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401 && withRelogin) {
          await _relogin(e);
          return await delete(
            path: path,
            headers: headers,
            isAuth: isAuth,
            withRelogin: false,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<Response> patch({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool isAuth = true,
    bool withRelogin = true,
  }) async {
    try {
      Map<String, dynamic> nHeaders = await _getAuth(headers, isAuth);
      final Options options = Options(headers: nHeaders);
      return await _dio.patch(path, data: data, options: options);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401 && withRelogin) {
          await _relogin(e);
          return await put(
            path: path,
            data: data,
            headers: headers,
            isAuth: isAuth,
            withRelogin: false,
          );
        }
      }
      rethrow;
    }
  }
}
