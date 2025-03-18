import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/domain/usecases/auth/get_current_user.dart';
import 'package:mood_tracker/domain/usecases/auth/login_user.dart';
import 'package:mood_tracker/domain/usecases/auth/register_user.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_event.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_state.dart';
import 'package:mood_tracker/domain/repositories/auth_repository.dart';

import '../../../core/error/failures.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetCurrentUser getCurrentUser;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.getCurrentUser,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthCheckingStatus());

    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      final result = await getCurrentUser();
      result.fold(
            (failure) => emit(Unauthenticated()),
            (user) => emit(Authenticated(user)),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(
      LoginEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(LoginLoading());

    final result = await loginUser(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
          (failure) => emit(LoginFailure(failure.message)),
          (user) => emit(LoginSuccess(user)),
    );
  }

  Future<void> _onRegister(
      RegisterEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(RegisterLoading());

    final result = await registerUser(
      RegisterParams(
        email: event.email,
        username: event.username,
        password: event.password,
      ),
    );

    result.fold(
          (failure) {
        if (failure is ValidationFailure) {
          emit(RegisterFailure(
            failure.message,
            errors: failure.errors,
          ));
        } else {
          emit(RegisterFailure(failure.message));
        }
      },
          (user) => emit(RegisterSuccess(user)),
    );
  }

  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(LogoutLoading());

    final result = await authRepository.logout();

    result.fold(
          (failure) => emit(LogoutFailure(failure.message)),
          (_) => emit(LogoutSuccess()),
    );
  }
}