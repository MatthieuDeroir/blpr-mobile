import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mood_tracker/data/datasources/local/mood_entry_local_datasource.dart';
import 'package:mood_tracker/data/datasources/local/scale_local_datasource.dart';
import 'package:mood_tracker/data/datasources/remote/mood_entry_remote_datasource.dart';
import 'package:mood_tracker/data/datasources/remote/scale_remote_datasource.dart';

class SyncService {
  final MoodEntryLocalDataSource _moodEntryLocalDataSource;
  final MoodEntryRemoteDataSource _moodEntryRemoteDataSource;
  final ScaleLocalDataSource _scaleLocalDataSource;
  final ScaleRemoteDataSource _scaleRemoteDataSource;

  bool _isSyncing = false;
  Timer? _syncTimer;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isConnected = true; // Default to true for simplicity

  SyncService(
      this._moodEntryLocalDataSource,
      this._moodEntryRemoteDataSource,
      this._scaleLocalDataSource,
      this._scaleRemoteDataSource,
      );

  Future<void> initialize() async {
    // Setup periodic sync
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) => syncData());

    // Initial sync
    syncData();
  }

  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _connectivitySubscription?.cancel();
  }

  // A simple connectivity check
  // In a real app, this would use a proper connectivity package
  Future<bool> isOnline() async {
    try {
      // Try a lightweight network request
      await Future.delayed(const Duration(milliseconds: 300));
      return _isConnected;
    } catch (_) {
      return false;
    }
  }

  // Set connection status (for testing or UI control)
  void setConnectionStatus(bool isConnected) {
    _isConnected = isConnected;
  }

  Future<void> syncData() async {
    if (_isSyncing) return;

    final isConnected = await isOnline();
    if (!isConnected) return;

    _isSyncing = true;

    try {
      // Sync scales
      await _syncScales();

      // Sync mood entries
      await _syncMoodEntries();
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncScales() async {
    try {
      // Get scales from server
      final remoteScales = await _scaleRemoteDataSource.getAllScales();

      // Save scales to local storage
      await _scaleLocalDataSource.saveAllScales(remoteScales);
    } catch (e) {
      debugPrint('Error syncing scales: $e');
    }
  }

  Future<void> _syncMoodEntries() async {
    try {
      // Get unsynced entries
      final unsyncedEntries = await _moodEntryLocalDataSource.getUnsyncedEntries();

      // Upload each unsynced entry
      for (final entry in unsyncedEntries) {
        try {
          await _moodEntryRemoteDataSource.createMoodEntry(entry);
          await _moodEntryLocalDataSource.markAsSynced(entry.id);
        } catch (e) {
          debugPrint('Error syncing entry ${entry.id}: $e');
        }
      }

      // Get entries from server (limited to last 100 for performance)
      final remoteEntries = await _moodEntryRemoteDataSource.getMoodEntries(limit: 100);

      // Save entries to local storage
      await _moodEntryLocalDataSource.saveAllMoodEntries(remoteEntries);
    } catch (e) {
      debugPrint('Error syncing mood entries: $e');
    }
  }

  Future<bool> forceSyncData() async {
    if (_isSyncing) return false;

    final isConnected = await isOnline();
    if (!isConnected) return false;

    await syncData();
    return true;
  }
}