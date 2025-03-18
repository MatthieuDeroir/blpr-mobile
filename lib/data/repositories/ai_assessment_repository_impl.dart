import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/core/network/network_info.dart';
import 'package:mood_tracker/data/datasources/remote/ai_assessment_remote_datasource.dart';
import 'package:mood_tracker/data/models/mood/mood_entry_model.dart';
import 'package:mood_tracker/domain/entities/ai_assessment.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/repositories/ai_assessment_repository.dart';
import 'package:mood_tracker/domain/repositories/mood_entry_repository.dart';
import 'package:mood_tracker/domain/usecases/ai/chat_with_ai.dart';

class AiAssessmentRepositoryImpl implements AiAssessmentRepository {
  final AiAssessmentRemoteDataSource remoteDataSource;
  final MoodEntryRepository moodEntryRepository;
  final NetworkInfo networkInfo;

  AiAssessmentRepositoryImpl({
    required this.remoteDataSource,
    required this.moodEntryRepository,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AiChatResponse>> chatWithAi({required String message}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.chatWithAi(message: message);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException {
        return const Left(ConnectionFailure());
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(ConnectionFailure(message: 'No internet connection. AI features require an internet connection.'));
    }
  }

  @override
  Future<Either<Failure, AiAssessment>> generateAssessment({
    required List<Map<String, dynamic>> conversation,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final assessment = await remoteDataSource.generateAssessment(conversation: conversation);
        return Right(assessment);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException {
        return const Left(ConnectionFailure());
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(ConnectionFailure(message: 'No internet connection. AI features require an internet connection.'));
    }
  }

  @override
  Future<Either<Failure, MoodEntry>> saveAssessment({
    required List<MoodScaleValue> scaleValues,
    String? comment,
    String? medication,
    double? sleepHours,
  }) async {
    try {
      // Use the mood entry repository to create a new entry
      return await moodEntryRepository.createMoodEntry(
        entryDate: DateTime.now(),
        comment: comment,
        medication: medication,
        sleepHours: sleepHours,
        scaleValues: scaleValues,
      );
    } catch (e) {
      debugPrint('Error saving assessment: $e');
      return Left(UnknownFailure(message: 'Failed to save assessment: $e'));
    }
  }
}