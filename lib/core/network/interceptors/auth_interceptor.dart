import 'package:dio/dio.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(AppConstants.tokenKey);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token expiration or authentication error
      // You could dispatch an event to log the user out
      // or refresh the token if you implement token refresh
    }
    return handler.next(err);
  }
}