// Add these imports at the top of the file
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/domain/usecases/scale/create_scale.dart';
import 'package:mood_tracker/domain/usecases/scale/delete_scale.dart';
import 'package:mood_tracker/domain/usecases/scale/update_scale.dart';
import 'package:mood_tracker/presentation/bloc/scale/scales_event.dart';
import 'package:mood_tracker/presentation/bloc/scale/scales_state.dart';

import '../../../domain/entities/scale.dart';
import '../../../domain/usecases/scale/get_scales.dart';

class ScalesBloc extends Bloc<ScalesEvent, ScalesState> {
  final GetScales getScales;
  final CreateScale createScale;
  final UpdateScale updateScale;
  final DeleteScale deleteScale;

  ScalesBloc({
    required this.getScales,
    required this.createScale,
    required this.updateScale,
    required this.deleteScale,
  }) : super(ScalesInitial()) {
    on<LoadScales>(_onLoadScales);
    on<CreateScaleEvent>(_onCreateScale);
    on<UpdateScaleEvent>(_onUpdateScale);
    on<DeleteScaleEvent>(_onDeleteScale);
    on<FilterScales>(_onFilterScales);
  }

  Future<void> _onLoadScales(
      LoadScales event,
      Emitter<ScalesState> emit,
      ) async {
    emit(ScalesLoading());

    final result = await getScales(const GetScalesParams());

    result.fold(
          (failure) => emit(ScalesError(failure.message)),
          (scales) {
        // Filter active scales if requested
        final filteredScales = event.activeOnly
            ? scales.where((scale) => scale.isActive).toList()
            : scales;

        // Split into default and custom scales
        final defaultScales = filteredScales.where((scale) => scale.isDefault).toList();
        final customScales = filteredScales.where((scale) => !scale.isDefault).toList();

        emit(ScalesLoaded(
          scales: filteredScales,
          defaultScales: defaultScales,
          customScales: customScales,
        ));
      },
    );
  }

  Future<void> _onCreateScale(
      CreateScaleEvent event,
      Emitter<ScalesState> emit,
      ) async {
    emit(ScalesLoading());

    final result = await createScale(CreateScaleParams(
      name: event.name,
      description: event.description,
      minValue: event.minValue,
      maxValue: event.maxValue,
      isActive: event.isActive,
      levels: event.levels,
    ));

    result.fold(
          (failure) => emit(ScalesError(failure.message)),
          (scale) {
        // Reload all scales to keep the state updated
        add(LoadScales());
      },
    );
  }

  Future<void> _onUpdateScale(
      UpdateScaleEvent event,
      Emitter<ScalesState> emit,
      ) async {
    emit(ScalesLoading());

    final result = await updateScale(UpdateScaleParams(
      id: event.id,
      name: event.name,
      description: event.description,
      isActive: event.isActive,
      levels: event.levels,
    ));

    result.fold(
          (failure) => emit(ScalesError(failure.message)),
          (scale) {
        // Reload all scales to keep the state updated
        add(LoadScales());
      },
    );
  }

  Future<void> _onDeleteScale(
      DeleteScaleEvent event,
      Emitter<ScalesState> emit,
      ) async {
    final currentState = state;
    if (currentState is ScalesLoaded) {
      // Optimistic update
      final updatedScales = List<Scale>.from(currentState.scales)
        ..removeWhere((scale) => scale.id == event.id);

      final updatedCustomScales = List<Scale>.from(currentState.customScales)
        ..removeWhere((scale) => scale.id == event.id);

      emit(ScalesLoaded(
        scales: updatedScales,
        defaultScales: currentState.defaultScales,
        customScales: updatedCustomScales,
      ));

      final result = await deleteScale(DeleteScaleParams(id: event.id));

      result.fold(
            (failure) {
          // Revert on failure
          emit(ScalesError(failure.message));
          add(LoadScales());
        },
            (_) => null, // Already updated optimistically
      );
    }
  }

  void _onFilterScales(
      FilterScales event,
      Emitter<ScalesState> emit,
      ) {
    final currentState = state;
    if (currentState is ScalesLoaded) {
      // Filter scales based on criteria
      final filteredScales = currentState.scales.where((scale) {
        // Apply name filter if provided
        if (event.nameFilter != null && event.nameFilter!.isNotEmpty) {
          if (!scale.name.toLowerCase().contains(event.nameFilter!.toLowerCase())) {
            return false;
          }
        }

        // Apply active filter if provided
        if (event.activeOnly) {
          if (!scale.isActive) {
            return false;
          }
        }

        return true;
      }).toList();

      // Split into default and custom scales
      final filteredDefaultScales = filteredScales.where((scale) => scale.isDefault).toList();
      final filteredCustomScales = filteredScales.where((scale) => !scale.isDefault).toList();

      emit(ScalesLoaded(
        scales: filteredScales,
        defaultScales: filteredDefaultScales,
        customScales: filteredCustomScales,
        nameFilter: event.nameFilter,
        activeOnly: event.activeOnly,
      ));
    }
  }
}