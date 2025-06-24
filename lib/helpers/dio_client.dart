import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class DioClient {
  static late Dio dio;

  static void init() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://moviltika-production.up.railway.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      extra: {
        'withCredentials': true, // 👈 NECESARIO para cookies
      },
      validateStatus: (status) => status != null && status < 500,
    ));

    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        print('❌ Error Dio: ${e.message}');
        print('➡️ URL: ${e.requestOptions.uri}');
        print('↩️ Status: ${e.response?.statusCode}');
        print('📦 Data: ${e.response?.data}');
        return handler.next(e);
      },
      onRequest: (options, handler) {
        print('➡️ Enviando request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Respuesta: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
    ));
  }
}
