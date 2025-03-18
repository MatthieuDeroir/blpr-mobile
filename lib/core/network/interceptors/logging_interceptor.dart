import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i(
      '📡 REQUEST[${options.method}] => PATH: ${options.path}\n'
          'Headers: ${options.headers}\n'
          'Body: ${options.data}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      '📡 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
          'Response: ${response.data}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '📡 ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\n'
          'Error Message: ${err.message}\n'
          'Error Response: ${err.response?.data}',
    );
    super.onError(err, handler);
  }
}