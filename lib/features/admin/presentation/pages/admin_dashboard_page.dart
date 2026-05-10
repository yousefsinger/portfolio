import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/particles_background.dart';
import '../../../portfolio/presentation/cubit/portfolio_cubit.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/certificates_tab.dart';
import '../widgets/opinions_tab.dart';
import '../widgets/profile_tab.dart';
import '../widgets/projects_tab.dart';
import '../widgets/skills_tab.dart';
import '../widgets/experiences_tab.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AdminCubit>()),
        BlocProvider(create: (_) => sl<PortfolioCubit>()..loadPortfolio()),
      ],
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatefulWidget {
  const _AdminDashboardView();

  @override
  State<_AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<_AdminDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<PortfolioCubit>().loadPortfolio();
        } else if (state is AdminError) {
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
        body: Padding(
          padding:  EdgeInsets.symmetric(vertical: 20),
          child: ParticlesBackground(
            child: Column(
              children: [
                _buildTopBar(context),
                Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBg.withValues(alpha: 0.95)
                      : AppColors.lightBg.withValues(alpha: 0.95),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.purple,
                    labelColor: AppColors.purple,
                    unselectedLabelColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Skills'),
                      Tab(text: 'Projects'),
                      Tab(text: 'Experiences'),
                      Tab(text: 'Certificates'),
                      Tab(text: 'Opinions'),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<PortfolioCubit, PortfolioState>(
                    builder: (context, state) {
                      if (state is PortfolioLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            ProfileTab(profile: state.data.profile),
                            SkillsTab(skills: state.data.skills),
                            ProjectsTab(projects: state.data.projects),
                            ExperiencesTab(experiences: state.data.experiences),
                            CertificatesTab(
                                certificates: state.data.certificates),
                            OpinionsTab(opinions: state.data.opinions),
                          ],
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.purple),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: AppSizes.navHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkBg : AppColors.lightBg)
            .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : AppColors.purple)
                .withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'YA.',
            style: TextStyle(
              color: AppColors.purple,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
            ),
            child: const Text(
              'Admin Mode',
              style: TextStyle(color: AppColors.purple, fontSize: 12),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () =>
                context.go(AppRouter.portfolio, extra: {'isAdmin': true}),
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('View Portfolio'),
            style: TextButton.styleFrom(foregroundColor: AppColors.cyan),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.go(AppRouter.roleSelection),
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text('Logout'),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
          ),
        ],
      ),
    );
  }
}
