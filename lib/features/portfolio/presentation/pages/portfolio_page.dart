import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/particles_background.dart';
import '../cubit/portfolio_cubit.dart';
import '../widgets/portfolio_navbar.dart';
import '../widgets/home_section.dart';
import '../widgets/about_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/certificates_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/cv_viewer.dart';
import '../widgets/experience_section.dart';
import '../widgets/opinions_section.dart';
import '../widgets/portfolio_states.dart';

class PortfolioPage extends StatelessWidget {
  final bool isAdmin;
  const PortfolioPage({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PortfolioCubit>()..loadPortfolio(),
      child: _PortfolioView(isAdmin: isAdmin),
    );
  }
}

class _PortfolioView extends StatefulWidget {
  final bool isAdmin;
  const _PortfolioView({required this.isAdmin});

  @override
  State<_PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<_PortfolioView> {
  final _scrollController = ScrollController();
  late final ValueNotifier<int> _activeSectionNotifier;

  final _homeKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _experienceKey = GlobalKey();
  final _certificatesKey = GlobalKey();
  final _opinionsKey = GlobalKey();
  final _contactKey = GlobalKey();

  late List<GlobalKey> _sectionKeys;

  @override
  void initState() {
    super.initState();
    _activeSectionNotifier = ValueNotifier<int>(0);
    _sectionKeys = [
      _homeKey,
      _aboutKey,
      _skillsKey,
      _projectsKey,
      _certificatesKey,
      _opinionsKey,
      _contactKey,
    ]; // Can dynamically insert `_experienceKey` in build
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    for (int i = _sectionKeys.length - 1; i >= 0; i--) {
      final ctx = _sectionKeys[i].currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null) {
          final pos = box.localToGlobal(Offset.zero);
          if (pos.dy <= AppSizes.navHeight + 50) {
            if (_activeSectionNotifier.value != i) {
              _activeSectionNotifier.value = i;
            }
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _activeSectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PortfolioCubit, PortfolioState>(
        builder: (context, state) {
          if (state is PortfolioLoading || state is PortfolioInitial) {
            return const PortfolioLoadingView();
          }
          if (state is PortfolioError) {
            return PortfolioErrorView(
              message: state.message,
              onRetry: () => context.read<PortfolioCubit>().loadPortfolio(),
            );
          }

          final data = (state as PortfolioLoaded).data;
          final bool hasExperiences = data.experiences.isNotEmpty;

          // Rebuild section keys dynamically based on active sections
          _sectionKeys = [
            _homeKey,
            _aboutKey,
            _skillsKey,
            _projectsKey,
            if (hasExperiences) _experienceKey,
            _certificatesKey,
            _opinionsKey,
            _contactKey,
          ];

          return Stack(
            children: [
              const Positioned.fill(
                child: ParticlesBackground(child: SizedBox.expand()),
              ),
              Column(
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: _activeSectionNotifier,
                    builder: (context, activeIndex, _) {
                      return PortfolioNavbar(
                        activeIndex: activeIndex,
                        isAdmin: widget.isAdmin,
                        hasExperiences: hasExperiences,
                        onNavItemTap: _scrollToSection,
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          _buildSection(
                              _homeKey,
                              HomeSection(
                                name: data.profile.name,
                                title: data.profile.title,
                                subtitle: data.profile.subtitle,
                                photoUrl: data.profile.photoUrl,
                                githubUrl: data.profile.github,
                                linkedinUrl: data.profile.linkedin,
                                email: data.profile.email,
                                hasCv: data.profile.cvUrl.trim().isNotEmpty,
                                onViewProjects: () => _scrollToSection(3),
                                onDownloadCV: () => CvViewerDialog.show(
                                  context,
                                  cvUrl: data.profile.cvUrl,
                                ),
                              )),
                          _buildSection(
                              _aboutKey,
                              AboutSection(
                                bio: data.profile.bio,
                                badges: data.profile.badges,
                              )),
                          const SizedBox(height: 120),
                          _buildSection(
                              _skillsKey, SkillsSection(skills: data.skills)),
                          const SizedBox(height: 120),
                          _buildSection(_projectsKey,
                              ProjectsSection(projects: data.projects)),
                          if (hasExperiences) ...[
                            const SizedBox(height: 120),
                            _buildSection(
                              _experienceKey,
                              ExperienceSection(
                                experiences: data.experiences,
                              ),
                            ),
                          ],
                          const SizedBox(height: 120),
                          _buildSection(
                              _certificatesKey,
                              CertificatesSection(
                                certificates: data.certificates,
                              )),
                          const SizedBox(height: 120),
                          _buildSection(
                            _opinionsKey,
                            OpinionsSection(opinions: data.opinions),
                          ),
                          const SizedBox(height: 120),
                          _buildSection(
                            _contactKey,
                            ContactSection(
                              email: data.profile.email,
                              phone: data.profile.phone,
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(Key key, Widget child) {
    return KeyedSubtree(key: key, child: child);
  }

  void _scrollToSection(int index) {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null) {
        final position = box.localToGlobal(Offset.zero);
        final currentScroll = _scrollController.offset;
        final target = position.dy + currentScroll - AppSizes.navHeight - 20;

        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
        );
      }
    }
  }
}
