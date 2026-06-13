import 'dart:io';
import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import '../../../core/services/network_service.dart';

class AuthApiService extends GetxService {
  late final dio_lib.Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Get.find<NetworkService>().dio;
  }

  /// Registration endpoint
  Future<dio_lib.Response> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    File? photo,
  }) async {
    final Map<String, dynamic> dataMap = {
      'username': username,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    };

    if (photo != null) {
      final fileName = photo.path.split('/').last;
      dataMap['photo'] = await dio_lib.MultipartFile.fromFile(
        photo.path,
        filename: fileName,
      );
    }

    final formData = dio_lib.FormData.fromMap(dataMap);

    return await _dio.post('/auth/register/', data: formData);
  }

  /// Login endpoint
  Future<dio_lib.Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      '/auth/login/',
      data: {'email': email, 'password': password},
    );
  }

  /// Get Profile endpoint
  Future<dio_lib.Response> getProfile() async {
    return await _dio.get('/auth/profile/');
  }

  /// Update Profile endpoint
  Future<dio_lib.Response> updateProfile({
    String? username,
    File? photo,
  }) async {
    final Map<String, dynamic> dataMap = {};

    if (username != null) {
      dataMap['username'] = username;
    }

    if (photo != null) {
      final fileName = photo.path.split('/').last;
      dataMap['photo'] = await dio_lib.MultipartFile.fromFile(
        photo.path,
        filename: fileName,
      );
    }

    final formData = dio_lib.FormData.fromMap(dataMap);

    return await _dio.post('/auth/update_profile/', data: formData);
  }

  /// Google Sign In endpoint
  Future<dio_lib.Response> googleLogin({
    required String googleId,
    required String email,
    required String idToken,
    required String name,
    required String photoUrl,
  }) async {
    return await _dio.post(
      '/auth/google-login/',
      data: {
        'google_id': googleId,
        'email': email,
        'id_token': idToken,
        'name': name,
        'photo_url': photoUrl,
      },
    );
  }

  /// Change Password endpoint
  Future<dio_lib.Response> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _dio.post(
      '/auth/change-password/',
      data: {'new_password': newPassword, 'confirm_password': confirmPassword},
    );
  }

  /// Forget Password endpoint
  Future<dio_lib.Response> forgotPassword({required String email}) async {
    return await _dio.post('/auth/forgot-password/', data: {'email': email});
  }

  /// Reset Password endpoint
  Future<dio_lib.Response> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _dio.post(
      '/auth/reset-password/',
      data: {'new_password': newPassword, 'confirm_password': confirmPassword},
    );
  }

  /// Logout endpoint
  Future<dio_lib.Response> logout({required String refreshToken}) async {
    return await _dio.post(
      '/auth/logout/',
      data: {'refresh_token': refreshToken},
    );
  }
}
