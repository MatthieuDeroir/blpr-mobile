// lib/data/datasources/local/mood_entry_local_datasource.dart
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/data/models/mood/mood_entry_model.dart';

abstract class MoodEntryLocalDataSource {
  Future<List<MoodEntryModel>> getAllMoodEntries();
  Future<MoodEntryModel?> getMoodEntryById(String id);
  Future<bool> saveMoodEntry(MoodEntryModel entry);
  Future<bool> deleteMoodEntry(String id);
  Future<bool> saveAllMoodEntries(List<MoodEntryModel> entries);
  Future<bool> clearMoodEntries();
  Future<List<MoodEntryModel>> getUnsyncedEntries();
  Future<bool> markAsSynced(String id);
}

class MoodEntryLocalDataSourceImpl implements MoodEntryLocalDataSource {
  final HiveInterface _hive;

  MoodEntryLocalDataSourceImpl(this._hive);

  Future<Box<String>> _getMoodEntriesBox() async {
    return await _hive.openBox<String>(AppConstants.moodEntriesBox);
  }

  @override
  Future<List<MoodEntryModel>> getAllMoodEntries() async {
    try {
      final box = await _getMoodEntriesBox();
      final entries = <MoodEntryModel>[];

      for (var key in box.keys) {
        if (key.toString().startsWith('entry_')) {
          final json = jsonDecode(box.get(key)!);
          entries.add(MoodEntryModel.fromJson(json));
        }
      }

      // Sort by date, newest first
      entries.sort((a, b) => b.entryDate.compareTo(a.entryDate));
      return entries;
    } catch (e) {
      throw CacheException('Failed to get mood entries: $e');
    }
  }

  @override
  Future<MoodEntryModel?> getMoodEntryById(String id) async {
    try {
      final box = await _getMoodEntriesBox();
      final entryJson = box.get('entry_$id');
      if (entryJson == null) return null;

      return MoodEntryModel.fromJson(jsonDecode(entryJson));
    } catch (e) {
      throw CacheException('Failed to get mood entry: $e');
    }
  }

  @override
  Future<bool> saveMoodEntry(MoodEntryModel entry) async {
    try {
      final box = await _getMoodEntriesBox();
      await box.put('entry_${entry.id}', jsonEncode(entry.toJson()));

      // Mark as unsynced if it's a new entry
      if (!box.containsKey('synced_${entry.id}')) {
        await box.put('synced_${entry.id}', 'false');
      }

      return true;
    } catch (e) {
      throw CacheException('Failed to save mood entry: $e');
    }
  }

  @override
  Future<bool> deleteMoodEntry(String id) async {
    try {
      final box = await _getMoodEntriesBox();
      await box.delete('entry_$id');
      await box.delete('synced_$id');
      return true;
    } catch (e) {
      throw CacheException('Failed to delete mood entry: $e');
    }
  }

  @override
  Future<bool> saveAllMoodEntries(List<MoodEntryModel> entries) async {
    try {
      final box = await _getMoodEntriesBox();

      final Map<String, String> entriesMap = {};
      final Map<String, String> syncedMap = {};

      for (var entry in entries) {
        entriesMap['entry_${entry.id}'] = jsonEncode(entry.toJson());
        syncedMap['synced_${entry.id}'] = 'true';
      }

      await box.putAll(entriesMap);
      await box.putAll(syncedMap);

      return true;
    } catch (e) {
      throw CacheException('Failed to save all mood entries: $e');
    }
  }

  @override
  Future<bool> clearMoodEntries() async {
    try {
      final box = await _getMoodEntriesBox();
      await box.clear();
      return true;
    } catch (e) {
      throw CacheException('Failed to clear mood entries: $e');
    }
  }

  @override
  Future<List<MoodEntryModel>> getUnsyncedEntries() async {
    try {
      final box = await _getMoodEntriesBox();
      final unsynced = <MoodEntryModel>[];

      for (var key in box.keys) {
        if (key.toString().startsWith('entry_')) {
          final id = key.toString().replaceFirst('entry_', '');
          final syncStatus = box.get('synced_$id') ?? 'false';

          if (syncStatus == 'false') {
            final json = jsonDecode(box.get(key)!);
            unsynced.add(MoodEntryModel.fromJson(json));
          }
        }
      }

      return unsynced;
    } catch (e) {
      throw CacheException('Failed to get unsynced entries: $e');
    }
  }

  @override
  Future<bool> markAsSynced(String id) async {
    try {
      final box = await _getMoodEntriesBox();
      await box.put('synced_$id', 'true');
      return true;
    } catch (e) {
      throw CacheException('Failed to mark entry as synced: $e');
    }
  }
}