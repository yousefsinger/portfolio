import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/validate_admin_code_usecase.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  final ValidateAdminCodeUseCase _validateCode;
  AuthCubit(this._validateCode) : super(AuthInitial());

  void validateCode(String code) {
    emit(AuthLoading());
    final isValid = _validateCode(code);
    if (isValid) {
      emit(AuthSuccess());
    } else {
      emit(AuthFailure(AppStrings.invalidCode));
    }
  }
}
