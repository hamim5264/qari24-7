import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_x;
import 'connectivity_service.dart';

class NetworkService extends get_x.GetxService {
  late Dio _dio;
  final String baseUrl = "https://google.com";

  Future<NetworkService> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final connectivity = get_x.Get.find<ConnectivityService>();
          if (!connectivity.isConnected.value) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: "No internet connection",
                type: DioExceptionType.connectionError,
              ),
            );
          }
          return handler.next(options);
        },
      ),
    );
    return this;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
}
