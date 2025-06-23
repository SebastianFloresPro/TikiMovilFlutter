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
      headers: {'Content-Type': 'application/json'},
    ));

    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  }
}