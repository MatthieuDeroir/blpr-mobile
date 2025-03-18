import 'dart:convert';

import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/data/datasources/local/local_storage.dart';
import 'package:mood_tracker/data/models/auth/user_model.dart';

abstract class AuthLocalDataSource {
  /// Save user token
  Future<bool> saveToken(String token);

  /// Get user token
  Future<String?> getToken();

  /// Save user info
  Future<bool> saveUser(UserModel user);

  /// Get user info
  Future<UserModel?> getUser();

  /// Set logged in status
  Future<bool> setLoggedIn(bool status);

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Clear all auth data (for logout)
  Future<bool> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage _localStorage;

  AuthLocalDataSourceImpl(this._localStorage);

  @override
  Future<bool> saveToken(String token) async {
    try {
      return await _localStorage.setString(AppConstants.tokenKey, token);
    } catch (e) {
      throw CacheException('Failed to save token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _localStorage.getString(AppConstants.tokenKey);
    } catch (e) {
      throw CacheException('Failed to get token: $e');
    }
  }

  @override
  Future<bool> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _localStorage.setString(AppConstants.userIdKey, user.id);
      await _localStorage.setString(AppConstants.userEmailKey, user.email);
      await _localStorage.setString(AppConstants.usernameKey, user.username);
      return true;
    } catch (e) {
      throw CacheException('Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final id = await _localStorage.getString(AppConstants.userIdKey);
      final email = await _localStorage.getString(AppConstants.userEmailKey);
      final username = await _localStorage.getString(AppConstants.usernameKey);

      if (id != null && email != null && username != null) {
        return UserModel(
          id: id,
          email: email,
          username: username,
        );
      }

      return null;
    } catch (e) {
      throw CacheException('Failed to get user: $e');
    }
  }

  @override
  Future<bool> setLoggedIn(bool status) async {
    try {
      return await _localStorage.setBool(AppConstants.isLoggedInKey, status);
    } catch (e) {
      throw CacheException('Failed to set login status: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await _localStorage.getBool(AppConstants.isLoggedInKey) ?? false;
    } catch (e) {
      throw CacheException('Failed to get login status: $e');
    }
  }

  @override
  Future<bool> clearAuthData() async {
    try {
      await _localStorage.remove(AppConstants.tokenKey);
      await _localStorage.remove(AppConstants.userIdKey);
      await _localStorage.remove(AppConstants.userEmailKey);
      await _localStorage.remove(AppConstants.usernameKey);
      await _localStorage.remove(AppConstants.isLoggedInKey);
      return true;
    } catch (e) {
      throw CacheException('Failed to clear auth data: $e');
    }
  }
}