import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

class AuthRepository extends GetxService {
  final isLogged = false.obs;
  final accessToken = "".obs;
  final refreshToken = "".obs;
  final currentUser = Rxn<UserModel>();

  late final AuthApiService _apiService;

  static const String _keyAccess = 'auth_access_token';
  static const String _keyRefresh = 'auth_refresh_token';
  static const String _keyUser = 'auth_user_data';

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<AuthApiService>();
    loadSession();
  }

  /// Load session from SharedPreferences
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final access = prefs.getString(_keyAccess);
      final refresh = prefs.getString(_keyRefresh);
      final userJson = prefs.getString(_keyUser);

      if (access != null && access.isNotEmpty) {
        accessToken.value = access;
        refreshToken.value = refresh ?? "";
        if (userJson != null) {
          currentUser.value = UserModel.fromJson(jsonDecode(userJson));
        }
        isLogged.value = true;
      }
    } catch (e) {
      isLogged.value = false;
    }
  }

  /// Save session to SharedPreferences
  Future<void> saveSession(
    String access,
    String refresh,
    UserModel user,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccess, access);
      await prefs.setString(_keyRefresh, refresh);
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));

      accessToken.value = access;
      refreshToken.value = refresh;
      currentUser.value = user;
      isLogged.value = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear session
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAccess);
      await prefs.remove(_keyRefresh);
      await prefs.remove(_keyUser);

      accessToken.value = "";
      refreshToken.value = "";
      currentUser.value = null;
      isLogged.value = false;
    } catch (e) {
      rethrow;
    }
  }

  /// Register user
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    File? photo,
  }) async {
    try {
      final response = await _apiService.register(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        photo: photo,
      );

      // Registration endpoint says "with a token" in response
      final data = response.data;
      if (data is Map<String, dynamic>) {
        // If registration returns login-like payload directly
        if (data.containsKey('access') && data.containsKey('user')) {
          final user = UserModel.fromJson(data['user']);
          final access = data['access'] as String;
          final refresh = data['refresh'] as String? ?? "";
          await saveSession(access, refresh, user);
          return user;
        } else {
          // Check if there is an access token or token, and also check if we have a valid user id.
          final access = data['token'] as String? ?? data['access'] as String?;
          final userMap = data['user'] as Map<String, dynamic>? ?? data;
          if (access != null &&
              userMap.containsKey('id') &&
              userMap['id'] != null) {
            final user = UserModel.fromJson(userMap);
            final refresh = data['refresh'] as String? ?? "";
            await saveSession(access, refresh, user);
            return user;
          } else {
            // If tokens are missing or the user payload doesn't contain a valid ID, trigger login directly.
            return await login(email: email, password: password);
          }
        }
      }
      throw "Invalid registration response format";
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Login user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final user = UserModel.fromJson(data['user']);
        final access = data['access'] as String;
        final refresh = data['refresh'] as String;
        await saveSession(access, refresh, user);
        return user;
      }
      throw "Invalid login response format";
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Google Sign In
  Future<UserModel> googleLogin({
    required String googleId,
    required String email,
    required String idToken,
    required String name,
    required String photoUrl,
  }) async {
    try {
      final response = await _apiService.googleLogin(
        googleId: googleId,
        email: email,
        idToken: idToken,
        name: name,
        photoUrl: photoUrl,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        // Typically google login returns tokens, if so save session
        final access = data['access'] as String? ?? data['token'] as String?;
        final refresh = data['refresh'] as String? ?? "";

        final userMap = data['user'] ?? data;
        final user = UserModel.fromJson(userMap);

        if (access != null) {
          await saveSession(access, refresh, user);
        }
        return user;
      }
      throw "Invalid Google sign in response format";
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.getProfile();
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('user')) {
        final user = UserModel.fromJson(data['user']);
        currentUser.value = user;
        // Update user cache in storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUser, jsonEncode(user.toJson()));
        return user;
      }
      throw "Invalid profile response format";
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update Profile
  Future<UserModel> updateProfile({String? username, File? photo}) async {
    try {
      debugPrint(
        "AuthRepository.updateProfile: username=$username, photo=${photo?.path}",
      );
      final response = await _apiService.updateProfile(
        username: username,
        photo: photo,
      );
      final data = response.data;
      debugPrint("AuthRepository.updateProfile success response: $data");

      if (data is Map<String, dynamic>) {
        final Map<String, dynamic> userMap = data.containsKey('user')
            ? (data['user'] as Map<String, dynamic>? ?? {})
            : data;

        final current = currentUser.value;
        if (current != null) {
          final updatedUser = UserModel(
            id: current.id,
            username:
                userMap['username'] as String? ??
                userMap['name'] as String? ??
                current.username,
            email: userMap['email'] as String? ?? current.email,
            photo:
                userMap['photo'] as String? ??
                userMap['photo_url'] as String? ??
                current.photo,
          );
          currentUser.value = updatedUser;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyUser, jsonEncode(updatedUser.toJson()));
          return updatedUser;
        }
      }
      throw "Invalid update profile response format";
    } catch (e) {
      debugPrint("AuthRepository.updateProfile caught error: $e");
      throw _handleError(e);
    }
  }

  /// Change Password
  Future<void> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiService.changePassword(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Forgot Password
  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiService.forgotPassword(email: email);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset Password
  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiService.resetPassword(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final token = refreshToken.value;
      if (token.isNotEmpty) {
        await _apiService.logout(refreshToken: token);
      }
    } catch (_) {
      // Ignore API failure on logout, we still clear the local session
    } finally {
      await clearSession();
    }
  }

  /// Error Handler helper
  String _handleError(dynamic error) {
    debugPrint("AuthRepository encountered error: $error");
    if (error is DioException) {
      debugPrint("DioException request path: ${error.requestOptions.path}");
      debugPrint("DioException response status: ${error.response?.statusCode}");
      debugPrint("DioException response data: ${error.response?.data}");

      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return "No internet connection or server timeout. Please try again.";
      }
      if (error.response != null && error.response!.data != null) {
        final data = error.response!.data;
        if (data is Map) {
          if (data.containsKey('message')) return data['message'].toString();
          if (data.containsKey('error')) return data['error'].toString();
          if (data.containsKey('detail')) return data['detail'].toString();

          final errors = data.entries
              .map((e) {
                final val = e.value;
                if (val is List) {
                  return "${e.key}: ${val.join(', ')}";
                }
                return "${e.key}: $val";
              })
              .join('\n');

          if (errors.isNotEmpty) return errors;
        }
      }
      return error.message ?? "An unexpected server error occurred.";
    }
    return error.toString();
  }
}
