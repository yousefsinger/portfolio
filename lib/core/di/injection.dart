import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/admin_usecases.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/validate_admin_code_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/portfolio/data/repositories/portfolio_repository_impl.dart';
import '../../features/portfolio/domain/repositories/portfolio_repository.dart';
import '../../features/portfolio/domain/usecases/get_portfolio_data_usecase.dart';
import '../../features/portfolio/domain/usecases/watch_portfolio_data_usecase.dart';
import '../../features/portfolio/domain/usecases/submit_opinion_usecase.dart';
import '../../features/portfolio/presentation/cubit/portfolio_cubit.dart';

import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  // External
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Theme
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
  sl.registerLazySingleton<ValidateAdminCodeUseCase>(
    () => ValidateAdminCodeUseCase(sl()),
  );
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl()),
  );

  // Portfolio
  sl.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetPortfolioDataUseCase>(
    () => GetPortfolioDataUseCase(sl()),
  );
  sl.registerLazySingleton<WatchPortfolioDataUseCase>(
    () => WatchPortfolioDataUseCase(sl()),
  );
  sl.registerLazySingleton<SubmitOpinionUseCase>(
    () => SubmitOpinionUseCase(sl()),
  );
  sl.registerFactory<PortfolioCubit>(
    () => PortfolioCubit(sl(), sl(), sl()),
  );

  // Admin
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(sl()),
  );
  sl.registerLazySingleton<AddSkillUseCase>(
    () => AddSkillUseCase(sl()),
  );
  sl.registerLazySingleton<AddProjectUseCase>(
    () => AddProjectUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateProjectUseCase>(
    () => UpdateProjectUseCase(sl()),
  );
  sl.registerLazySingleton<AddCertificateUseCase>(
    () => AddCertificateUseCase(sl()),
  );
  sl.registerLazySingleton<AddOpinionUseCase>(
    () => AddOpinionUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteSkillUseCase>(
    () => DeleteSkillUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteProjectUseCase>(
    () => DeleteProjectUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteCertificateUseCase>(
    () => DeleteCertificateUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteOpinionUseCase>(
    () => DeleteOpinionUseCase(sl()),
  );
  sl.registerLazySingleton<AddExperienceUseCase>(
    () => AddExperienceUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateExperienceUseCase>(
    () => UpdateExperienceUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteExperienceUseCase>(
    () => DeleteExperienceUseCase(sl()),
  );
  sl.registerFactory<AdminCubit>(
    () => AdminCubit(
      sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(),
    ),
  );
}
