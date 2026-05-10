import 'package:md_portfolio/core/constants/app_constants.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  bool validateAdminCode(String code) => code.trim() == AppStrings.adminCode;
}
