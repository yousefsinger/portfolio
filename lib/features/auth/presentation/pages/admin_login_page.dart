import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/particles_background.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../cubit/auth_cubit.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: const _AdminLoginView(),
    );
  }
}

class _AdminLoginView extends StatefulWidget {
  const _AdminLoginView();

  @override
  State<_AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<_AdminLoginView> {
  final _controller = TextEditingController();
  late final ValueNotifier<bool> _obscureNotifier;

  @override
  void initState() {
    super.initState();
    _obscureNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _obscureNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _showAdminOptions(context);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            ParticlesBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'YA.',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(color: AppColors.purple),
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 40),
                        GradientBorderCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.enterCode,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppColors.purple),
                              ),
                              const SizedBox(height: 24),
                              ValueListenableBuilder<bool>(
                                valueListenable: _obscureNotifier,
                                builder: (context, obscure, _) {
                                  return TextField(
                                    controller: _controller,
                                    obscureText: obscure,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your code',
                                      prefixIcon:
                                          const Icon(Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined),
                                        onPressed: () =>
                                            _obscureNotifier.value = !obscure,
                                      ),
                                    ),
                                    onSubmitted: (_) => _submit(context),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () => _submit(context),
                                      child: state is AuthLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Verify'),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () => context.go(AppRouter.roleSelection),
                                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                                label: const Text('Go back'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(
                              begin: 0.3,
                              end: 0,
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.go(AppRouter.roleSelection),
                tooltip: 'Back to Role Selection',
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<AuthCubit>().validateCode(_controller.text);
  }

  void _showAdminOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text(
          'Welcome, Admin!',
          style: TextStyle(color: AppColors.purple),
        ),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRouter.portfolio, extra: {'isAdmin': true});
            },
            child: const Text(AppStrings.viewMode),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRouter.adminDashboard);
            },
            child: const Text(AppStrings.editMode),
          ),
        ],
      ),
    );
  }
}
