import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/particles_background.dart';
import '../widgets/role_card.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticlesBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'YA.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.chooseRole,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ).animate(delay: 200.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.chooseRoleSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                    textAlign: TextAlign.center,
                  ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 60),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      RoleCard(
                        icon: Icons.person_outline_rounded,
                        title: AppStrings.visitor,
                        description: AppStrings.visitorDesc,
                        delay: 400,
                        onTap: () => context.go(
                          AppRouter.portfolio,
                          extra: {'isAdmin': false},
                        ),
                      ),
                      RoleCard(
                        icon: Icons.admin_panel_settings_outlined,
                        title: AppStrings.admin,
                        description: AppStrings.adminDesc,
                        delay: 500,
                        isPrimary: true,
                        onTap: () => context.go(AppRouter.adminLogin),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
