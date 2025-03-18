import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/domain/entities/stability_formula.dart';
import 'package:mood_tracker/domain/usecases/scale/create_formula.dart';
import 'package:mood_tracker/domain/usecases/scale/get_active_formula.dart';
import 'package:mood_tracker/domain/usecases/scale/get_formulas.dart';
import 'package:mood_tracker/domain/usecases/scale/update_formula.dart';
import 'package:mood_tracker/presentation/bloc/scale/formula_event.dart';
import 'package:mood_tracker/presentation/bloc/scale/formula_state.dart';

class FormulaBloc extends Bloc<FormulaEvent, FormulaState> {
  final GetFormulas getFormulas;
  final GetActiveFormula getActiveFormula;
  final CreateFormula createFormula;
  final UpdateFormula updateFormula;

  FormulaBloc({
    required this.getFormulas,
    required this.getActiveFormula,
    required this.createFormula,
    required this.updateFormula,
  }) : super(FormulaInitial()) {
    on<LoadFormulas>(_onLoadFormulas);
    on<LoadActiveFormula>(_onLoadActiveFormula);
    on<CreateFormulaEvent>(_onCreateFormula);
    on<UpdateFormulaEvent>(_onUpdateFormula);
    on<SetActiveFormula>(_onSetActiveFormula);
  }

  Future<void> _onLoadFormulas(
      LoadFormulas event,
      Emitter<FormulaState> emit,
      ) async {
    emit(FormulaLoading());

    final result = await getFormulas(const GetFormulasParams());

    result.fold(
          (failure) => emit(FormulaError(failure.message)),
          (formulas) {
        // Find active formula
        StabilityFormula? activeFormula;
        try {
          activeFormula = formulas.firstWhere((formula) => formula.isActive);
        } catch (_) {
          // No active formula found
        }

        emit(FormulasLoaded(
          formulas: formulas,
          activeFormula: activeFormula,
        ));
      },
    );
  }

  Future<void> _onLoadActiveFormula(
      LoadActiveFormula event,
      Emitter<FormulaState> emit,
      ) async {
    emit(FormulaLoading());

    final result = await getActiveFormula(const GetActiveFormulaParams());

    result.fold(
          (failure) => emit(FormulaError(failure.message)),
          (formula) => emit(ActiveFormulaLoaded(formula)),
    );
  }

  Future<void> _onCreateFormula(
      CreateFormulaEvent event,
      Emitter<FormulaState> emit,
      ) async {
    emit(FormulaLoading());

    final result = await createFormula(CreateFormulaParams(
      description: event.description,
      isActive: event.isActive,
      scaleWeights: event.scaleWeights,
    ));

    result.fold(
          (failure) => emit(FormulaError(failure.message)),
          (formula) {
        // Reload all formulas to keep the state updated
        add(LoadFormulas());
      },
    );
  }

  Future<void> _onUpdateFormula(
      UpdateFormulaEvent event,
      Emitter<FormulaState> emit,
      ) async {
    emit(FormulaLoading());

    final result = await updateFormula(UpdateFormulaParams(
      id: event.id,
      description: event.description,
      isActive: event.isActive,
      scaleWeights: event.scaleWeights,
    ));

    result.fold(
          (failure) => emit(FormulaError(failure.message)),
          (formula) {
        // Reload all formulas to keep the state updated
        add(LoadFormulas());
      },
    );
  }

  Future<void> _onSetActiveFormula(
      SetActiveFormula event,
      Emitter<FormulaState> emit,
      ) async {
    emit(FormulaLoading());

    // Update formula to make it active
    final result = await updateFormula(UpdateFormulaParams(
      id: event.id,
      isActive: true,
    ));

    result.fold(
          (failure) => emit(FormulaError(failure.message)),
          (formula) {
        // Reload all formulas to keep the state updated
        add(LoadFormulas());
      },
    );
  }
}