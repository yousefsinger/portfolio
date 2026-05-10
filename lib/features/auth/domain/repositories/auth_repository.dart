// domain/repositories/auth_repository.dart
abstract class AuthRepository {
  bool validateAdminCode(String code);
}
