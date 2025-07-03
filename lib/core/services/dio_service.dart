import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioService {
  late final Dio _dio;

  DioService() {
    _dio = Dio();
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          // final token = getTokenFromStorage();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Handle timeout errors
        break;
      case DioExceptionType.badResponse:
        // Handle HTTP errors
        break;
      case DioExceptionType.cancel:
        // Handle cancelled requests
        break;
      case DioExceptionType.unknown:
        // Handle other errors
        break;
      default:
        break;
    }
  }
}
