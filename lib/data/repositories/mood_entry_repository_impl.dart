import 'package:dartz/dartz.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/core/network/network_info.dart';
import 'package:mood_tracker/data/datasources/local/mood_entry_local_datasource.dart';
import 'package:mood_tracker/data/datasources/remote/mood_entry_remote_datasource.dart';
import 'package:mood_tracker/data/models/mood/mood_entry_model.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/repositories/mood_entry_repository.dart';

import '../../core/error/exceptions.dart';

class MoodEntryRepositoryImpl implements MoodEntryRepository {
  final MoodEntryRemoteDataSource remoteDataSource;
  final MoodEntryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MoodEntryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MoodEntry>>> getMoodEntries({int? limit, int? offset}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMoodEntries = await remoteDataSource.getMoodEntries(limit: limit, offset: offset);
        await localDataSource.saveAllMoodEntries(remoteMoodEntries);
        return Right(remoteMoodEntries);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException {
        return Left(const ConnectionFailure());
      }
    } else {
      try {
        final localMoodEntries = await localDataSource.getAllMoodEntries();
        return Right(localMoodEntries);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, MoodEntry>> getMoodEntryById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMoodEntry = await remoteDataSource.getMoodEntryById(id);
        await localDataSource.saveMoodEntry(remoteMoodEntry);
        return Right(remoteMoodEntry);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException {
        return Left(const ConnectionFailure());
      }
    } else {
      try {
        final localMoodEntry = await localDataSource.getMoodEntryById(id);
        return localMoodEntry != null
            ? Right(localMoodEntry)
            : Left(const NotFoundFailure(message: 'Mood entry not found'));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, MoodEntry>> createMoodEntry({
    required DateTime entryDate,
    String? comment,
    String? medication,
    double? sleepHours,
    required List<MoodScaleValue> scaleValues,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final moodEntryModel = MoodEntryModel(
          id: DateTime.now().toIso8601String(), // Temporary ID generation
          userId: '', // You'll need to set this dynamically
          entryDate: entryDate,
          comment: comment,
          medication: medication,
          sleepHours: sleepHours,
          scaleValues: scaleValues,
        );

        final createdMoodEntry = await remoteDataSource.createMoodEntry(moodEntryModel);
        await localDataSource.saveMoodEntry(createdMoodEntry);
        await localDataSource.markAsSynced(createdMoodEntry.id);
        return Right(createdMoodEntry);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException {
        // Save locally for later sync
        final moodEntryModel = MoodEntryModel(
          id: DateTime.now().toIso8601String(),
          userId: '', // You'll need to set this dynamically
          entryDate: entryDate,
          comment: comment,
          medication: medication,
          sleepHours: sleepHours,
          scaleValues: scaleValues,
        );
        await localDataSource.saveMoodEntry(moodEntryModel);
        return Right(moodEntryModel);
      }
    } else {
      // Save locally for later sync
      final moodEntryModel = MoodEntryModel(
        id: DateTime.now().toIso8601String(),
        userId: '', // You'll need to set this dynamically
        entryDate: entryDate,
        comment: comment,
        medication: medication,
        sleepHours: sleepHours,
        scaleValues: scaleValues,
      );
      await localDataSource.saveMoodEntry(moodEntryModel);
      return Right(moodEntryModel);
    }
  }

  @override
  Future<Either<Failure, MoodEntry>> updateMoodEntry({
    required String id,
    DateTime? entryDate,
    String? comment,
    String? medication,
    double? sleepHours,
    List<MoodScaleValue>? scaleValues,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final existingEntry = await localDataSource.getMoodEntryById(id);
        if (existingEntry == null) {
          return Left(const NotFoundFailure());
        }

        final updatedEntryModel = MoodEntryModel(
          id: id,
          userId: existingEntry.userId,
          entryDate: entryDate ?? existingEntry.entryDate,
          comment: comment ?? existingEntry.comment,
          medication: medication ?? existingEntry.medication,
          sleepHours: sleepHours ?? existingEntry.sleepHours,
          scaleValues: scaleValues ?? existingEntry.scaleValues,
        );

        final updatedMoodEntry = await remoteDataSource.updateMoodEntry(id, updatedEntryModel);
        await localDataSource.saveMoodEntry(updatedMoodEntry);
        await localDataSource.markAsSynced(updatedMoodEntry.id);
        return Right(updatedMoodEntry);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException {
        // Save locally with update mark
        final existingEntry = await localDataSource.getMoodEntryById(id);
        if (existingEntry == null) {
          return Left(const NotFoundFailure());
        }

        final updatedEntryModel = MoodEntryModel(
          id: id,
          userId: existingEntry.userId,
          entryDate: entryDate ?? existingEntry.entryDate,
          comment: comment ?? existingEntry.comment,
          medication: medication ?? existingEntry.medication,
          sleepHours: sleepHours ?? existingEntry.sleepHours,
          scaleValues: scaleValues ?? existingEntry.scaleValues,
        );

        await localDataSource.saveMoodEntry(updatedEntryModel);
        return Right(updatedEntryModel);
      }
    } else {
      // Save locally with update mark
      final existingEntry = await localDataSource.getMoodEntryById(id);
      if (existingEntry == null) {
        return Left(const NotFoundFailure());
      }

      final updatedEntryModel = MoodEntryModel(
        id: id,
        userId: existingEntry.userId,
        entryDate: entryDate ?? existingEntry.entryDate,
        comment: comment ?? existingEntry.comment,
        medication: medication ?? existingEntry.medication,
        sleepHours: sleepHours ?? existingEntry.sleepHours,
        scaleValues: scaleValues ?? existingEntry.scaleValues,
      );

      await localDataSource.saveMoodEntry(updatedEntryModel);
      return Right(updatedEntryModel);
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMoodEntry(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteMoodEntry(id);
        await localDataSource.deleteMoodEntry(id);
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException {
        return Left(const ConnectionFailure());
      }
    } else {
      try {
        await localDataSource.deleteMoodEntry(id);
        return const Right(true);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<MoodEntry>>> getMoodEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMoodEntries = await remoteDataSource.getMoodEntriesByDateRange(startDate, endDate);
        await localDataSource.saveAllMoodEntries(remoteMoodEntries);
        return Right(remoteMoodEntries);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException {
        return Left(const ConnectionFailure());
      }
    } else {
      try {
        final localMoodEntries = await localDataSource.getAllMoodEntries();
        final filteredEntries = localMoodEntries.where((entry) =>
        entry.entryDate.isAfter(startDate) && entry.entryDate.isBefore(endDate)).toList();
        return Right(filteredEntries);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }
}