import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/particles_background.dart';
import '../../domain/entities/portfolio_entities.dart';
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
import '../widgets/portfolio_footer.dart';
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

/// One section of the page and its navbar label.
class _Section {
  final String label;
  final Widget child;
  const _Section(this.label, this.child);
}

class _PortfolioView extends StatefulWidget {
  final bool isAdmin;
  const _PortfolioView({required this.isAdmin});

  @override
  State<_PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<_PortfolioView> {
  final _scrollController = ScrollController();
  final _activeSectionNotifier = ValueNotifier<int>(0);
  final _showTopButtonNotifier = ValueNotifier<bool>(false);

  /// One stable key per section label, used to find sections for scrolling.
  final Map<String, GlobalKey> _keys = {};
  List<String> _labels = const [];

  GlobalKey _keyFor(String label) => _keys.putIfAbsent(label, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _showTopButtonNotifier.value = _scrollController.offset > 600;

    // At the very bottom the last section may be too short to reach the top,
    // so highlight it explicitly.
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 4 && _labels.isNotEmpty) {
      _activeSectionNotifier.value = _labels.length - 1;
      return;
    }

    for (int i = _labels.length - 1; i >= 0; i--) {
      final box =
          _keyFor(_labels[i]).currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= AppSizes.navHeight + 50) {
        if (_activeSectionNotifier.value != i) {
          _activeSectionNotifier.value = i;
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _activeSectionNotifier.dispose();
    _showTopButtonNotifier.dispose();
    super.dispose();
  }

  /// Sections with no content are left out (and so are their nav links).
  List<_Section> _buildSections(
      BuildContext context, PortfolioDataEntity data) {
    final p = data.profile;
    return [
      _Section(
        AppStrings.home,
        HomeSection(
          name: p.name,
          title: p.title,
          subtitle: p.subtitle,
          photoUrl: p.photoUrl,
          githubUrl: p.github,
          linkedinUrl: p.linkedin,
          email: p.email,
          hasCv: p.cvUrl.trim().isNotEmpty,
          onViewProjects: () => _scrollToLabel(
            data.projects.isNotEmpty ? AppStrings.projects : AppStrings.contact,
          ),
          onDownloadCV: () => CvViewerDialog.show(context, cvUrl: p.cvUrl),
        ),
      ),
      if (p.bio.trim().isNotEmpty || p.badges.isNotEmpty)
        _Section(
          AppStrings.about,
          AboutSection(bio: p.bio, badges: p.badges),
        ),
      if (data.skills.isNotEmpty)
        _Section(AppStrings.skills, SkillsSection(skills: data.skills)),
      if (data.projects.isNotEmpty)
        _Section(
            AppStrings.projects, ProjectsSection(projects: data.projects)),
      if (data.experiences.isNotEmpty)
        _Section(
          AppStrings.experience,
          ExperienceSection(experiences: data.experiences),
        ),
      if (data.certificates.isNotEmpty)
        _Section(
          AppStrings.certificates,
          CertificatesSection(certificates: data.certificates),
        ),
      _Section(AppStrings.opinions, OpinionsSection(opinions: data.opinions)),
      _Section(
        AppStrings.contact,
        ContactSection(email: p.email, phone: p.phone),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;
    final gap = isMobile ? 32.0 : 120.0;

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
          final sections = _buildSections(context, data);
          _labels = [for (final s in sections) s.label];

          return Stack(
            children: [
              const Positioned.fill(
                child: ParticlesBackground(child: SizedBox.expand()),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width > 1400
                      ? 180
                      : width > 1000
                          ? 100
                          : isMobile
                              ? 20
                              : 30,
                ),
                child: Column(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: _activeSectionNotifier,
                      builder: (context, activeIndex, _) {
                        return PortfolioNavbar(
                          items: _labels,
                          activeIndex: activeIndex,
                          isAdmin: widget.isAdmin,
                          onNavItemTap: (i) => _scrollToLabel(_labels[i]),
                        );
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            for (int i = 0; i < sections.length; i++) ...[
                              // The original layout has no gap between Home
                              // and About.
                              if (i > 1) SizedBox(height: gap),
                              KeyedSubtree(
                                key: _keyFor(sections[i].label),
                                child: sections[i].child,
                              ),
                            ],
                            SizedBox(height: isMobile ? 24 : 60),
                            PortfolioFooter(name: data.profile.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: isMobile ? 16 : 28,
                bottom: isMobile ? 20 : 28,
                child: SafeArea(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _showTopButtonNotifier,
                    builder: (context, show, _) => _BackToTopButton(
                      visible: show,
                      onTap: _scrollToTop,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _scrollToLabel(String label) {
    if (label == AppStrings.home) return _scrollToTop();

    final box = _keys[label]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    // The scroll view starts below the navbar, so measure relative to it.
    final target = (box.localToGlobal(Offset.zero).dy +
            _scrollController.offset -
            AppSizes.navHeight -
            20)
        .clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }
}

class _BackToTopButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const _BackToTopButton({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1 : 0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Tooltip(
        message: 'Back to top',
        child: Material(
          color: AppColors.purple,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: AppColors.purple.withValues(alpha: 0.5),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.keyboard_arrow_up_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
