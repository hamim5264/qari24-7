import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as get_x;
import 'connectivity_service.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/screens/auth_welcome_screen.dart';

class NetworkService extends get_x.GetxService {
  late Dio dio;
  final String baseUrl = "https://quran-app-backend-8b57.onrender.com";

  Future<NetworkService> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
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

          // Inject Auth Token if registered (skip for token refresh request itself)
          if (get_x.Get.isRegistered<AuthRepository>() &&
              !options.path.contains('/auth/refresh/')) {
            final authRepository = get_x.Get.find<AuthRepository>();
            final token = authRepository.accessToken.value;
            if (token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },
        onError: (DioException err, handler) async {
          debugPrint(
            "NetworkService Interceptor onError: [${err.requestOptions.method}] ${err.requestOptions.path} | StatusCode: ${err.response?.statusCode}",
          );
          if (err.response?.statusCode == 401) {
            // Check if it's already a refresh request to avoid infinite loop
            if (err.requestOptions.path.contains('/auth/refresh/')) {
              debugPrint(
                "NetworkService: Token refresh request failed with 401. Clearing session and logging out.",
              );
              if (get_x.Get.isRegistered<AuthRepository>()) {
                final authRepository = get_x.Get.find<AuthRepository>();
                await authRepository.clearSession();
                get_x.Get.offAll(() => const AuthWelcomeScreen());
              }
              return handler.next(err);
            }

            if (get_x.Get.isRegistered<AuthRepository>()) {
              final authRepository = get_x.Get.find<AuthRepository>();
              final refresh = authRepository.refreshToken.value;

              if (refresh.isNotEmpty) {
                try {
                  debugPrint(
                    "NetworkService: Access token expired. Attempting token refresh using refresh token: ${refresh.substring(0, refresh.length > 10 ? 10 : refresh.length)}...",
                  );
                  // Perform refresh request
                  final response = await dio.post(
                    '/auth/refresh/',
                    data: {'refresh_token': refresh},
                  );

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    final data = response.data;
                    final newAccess = data['access'] as String;
                    final newRefresh = data['refresh'] as String? ?? refresh;

                    debugPrint(
                      "NetworkService: Token refresh succeeded. Saving new session.",
                    );
                    // Update session
                    final user = authRepository.currentUser.value;
                    if (user != null) {
                      await authRepository.saveSession(
                        newAccess,
                        newRefresh,
                        user,
                      );
                    }

                    // Retry original request
                    final requestOptions = err.requestOptions;
                    requestOptions.headers['Authorization'] =
                        'Bearer $newAccess';

                    debugPrint(
                      "NetworkService: Retrying original request [${requestOptions.method}] ${requestOptions.path}",
                    );
                    final retryResponse = await dio.request(
                      requestOptions.path,
                      options: Options(
                        method: requestOptions.method,
                        headers: requestOptions.headers,
                        contentType: requestOptions.contentType,
                        responseType: requestOptions.responseType,
                      ),
                      data: requestOptions.data,
                      queryParameters: requestOptions.queryParameters,
                    );
                    return handler.resolve(retryResponse);
                  }
                } catch (refreshErr) {
                  debugPrint(
                    "NetworkService: Token refresh caught error: $refreshErr",
                  );
                  // If refresh fails, log out
                  await authRepository.clearSession();
                  get_x.Get.offAll(() => const AuthWelcomeScreen());
                  return handler.next(err);
                }
              } else {
                debugPrint(
                  "NetworkService: No refresh token stored. Cannot refresh.",
                );
              }
            }
          }
          return handler.next(err);
        },
      ),
    );
    return this;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }
}
