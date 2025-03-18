// lib/data/datasources/local/scale_local_datasource.dart
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/data/models/scale/scale_model.dart';

abstract class ScaleLocalDataSource {
  Future<List<ScaleModel>> getAllScales();
  Future<ScaleModel?> getScaleById(String id);
  Future<bool> saveScale(ScaleModel scale);
  Future<bool> deleteScale(String id);
  Future<bool> saveAllScales(List<ScaleModel> scales);
  Future<bool> clearScales();
}

class ScaleLocalDataSourceImpl implements ScaleLocalDataSource {
  final HiveInterface _hive;

  ScaleLocalDataSourceImpl(this._hive);

  Future<Box<String>> _getScalesBox() async {
    return await _hive.openBox<String>(AppConstants.scalesBox);
  }

  @override
  Future<List<ScaleModel>> getAllScales() async {
    try {
      final box = await _getScalesBox();
      final scales = <ScaleModel>[];

      for (var key in box.keys) {
        if (key.toString().startsWith('scale_')) {
          final json = jsonDecode(box.get(key)!);
          scales.add(ScaleModel.fromJson(json));
        }
      }

      // Sort by name
      scales.sort((a, b) => a.name.compareTo(b.name));
      return scales;
    } catch (e) {
      throw CacheException('Failed to get scales: $e');
    }
  }

  @override
  Future<ScaleModel?> getScaleById(String id) async {
    try {
      final box = await _getScalesBox();
      final scaleJson = box.get('scale_$id');
      if (scaleJson == null) return null;

      return ScaleModel.fromJson(jsonDecode(scaleJson));
    } catch (e) {
      throw CacheException('Failed to get scale: $e');
    }
  }

  @override
  Future<bool> saveScale(ScaleModel scale) async {
    try {
      final box = await _getScalesBox();
      await box.put('scale_${scale.id}', jsonEncode(scale.toJson()));
      return true;
    } catch (e) {
      throw CacheException('Failed to save scale: $e');
    }
  }

  @override
  Future<bool> deleteScale(String id) async {
    try {
      final box = await _getScalesBox();
      await box.delete('scale_$id');
      return true;
    } catch (e) {
      throw CacheException('Failed to delete scale: $e');
    }
  }

  @override
  Future<bool> clearScales() {
    // TODO: implement clearScales
    throw UnimplementedError();
  }

  @override
  Future<bool> saveAllScales(List<ScaleModel> scales) {
    // TODO: implement saveAllScales
    throw UnimplementedError();
  }
}