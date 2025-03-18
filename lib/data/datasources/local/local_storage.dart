import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<bool> setString(String key, String value);
  Future<String?> getString(String key);
  Future<bool> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<bool> setInt(String key, int value);
  Future<int?> getInt(String key);
  Future<bool> setDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<bool> remove(String key);
  Future<bool> containsKey(String key);
  Future<bool> clear();
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _sharedPreferences;

  LocalStorageImpl(this._sharedPreferences);

  @override
  Future<bool> setString(String key, String value) async {
    try {
      return await _sharedPreferences.setString(key, value);
    } catch (e) {
      throw CacheException('Failed to save string: $e');
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _sharedPreferences.getString(key);
    } catch (e) {
      throw CacheException('Failed to get string: $e');
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _sharedPreferences.setBool(key, value);
    } catch (e) {
      throw CacheException('Failed to save boolean: $e');
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return _sharedPreferences.getBool(key);
    } catch (e) {
      throw CacheException('Failed to get boolean: $e');
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      return await _sharedPreferences.setInt(key, value);
    } catch (e) {
      throw CacheException('Failed to save integer: $e');
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return _sharedPreferences.getInt(key);
    } catch (e) {
      throw CacheException('Failed to get integer: $e');
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _sharedPreferences.setDouble(key, value);
    } catch (e) {
      throw CacheException('Failed to save double: $e');
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      return _sharedPreferences.getDouble(key);
    } catch (e) {
      throw CacheException('Failed to get double: $e');
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      return await _sharedPreferences.remove(key);
    } catch (e) {
      throw CacheException('Failed to remove key: $e');
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _sharedPreferences.containsKey(key);
    } catch (e) {
      throw CacheException('Failed to check key: $e');
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _sharedPreferences.clear();
    } catch (e) {
      throw CacheException('Failed to clear storage: $e');
    }
  }
}