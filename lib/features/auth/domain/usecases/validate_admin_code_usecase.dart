import '../repositories/auth_repository.dart';

class ValidateAdminCodeUseCase {
  final AuthRepository _repository;
  ValidateAdminCodeUseCase(this._repository);

  bool call(String code) => _repository.validateAdminCode(code);
}
