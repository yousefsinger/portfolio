import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/drive_url_helper.dart';
import 'social_icon.dart';

class HomeSection extends StatelessWidget {
  final String name;
  final String title;
  final String subtitle;
  final String photoUrl;
  final String githubUrl;
  final String linkedinUrl;
  final String email;
  final bool hasCv;
  final VoidCallback onViewProjects;
  final VoidCallback onDownloadCV;

  const HomeSection({
    super.key,
    required this.name,
    required this.title,
    required this.subtitle,
    required this.photoUrl,
    required this.githubUrl,
    required this.linkedinUrl,
    required this.email,
    required this.hasCv,
    required this.onViewProjects,
    required this.onDownloadCV,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: _buildTextContent(context, isDark)),
                  _buildPhoto(context),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPhoto(context),
                  const SizedBox(height: 32),
                  _buildTextContent(context, isDark),
                ],
              ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, bool isDark) {
    final socialItems = <Widget>[
      if (githubUrl.trim().isNotEmpty)
        SocialIcon(
          svgPath: 'assets/icons/githubicon.svg',
          url: githubUrl,
          tooltip: 'GitHub',
        ),
      if (linkedinUrl.trim().isNotEmpty)
        SocialIcon(
          svgPath: 'assets/icons/linkedinicon.svg',
          url: linkedinUrl,
          tooltip: 'LinkedIn',
        ),
      if (email.trim().isNotEmpty)
        SocialIcon(
          svgPath: 'assets/icons/gmailicon.svg',
          url: 'mailto:$email',
          tooltip: 'Email',
        ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.trim().isNotEmpty) ...[
          const Text(
            AppStrings.greeting,
            style: TextStyle(
              color: AppColors.cyan,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          const SizedBox(height: 8),
        ],
        Text(
          name,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.purple,
              ),
        ).animate(delay: 100.ms).fadeIn(duration: 600.ms).slideX(begin: -0.2),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.normal,
              ),
        ).animate(delay: 200.ms).fadeIn(duration: 600.ms),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
        ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
        const SizedBox(height: 40),
        Row(
          children: [
            ElevatedButton(
              onPressed: onViewProjects,
              child: const Text(AppStrings.viewProjects),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: hasCv ? onDownloadCV : null,
              child: const Text(AppStrings.downloadCV),
            ),
          ],
        ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3),
        if (socialItems.isNotEmpty) ...[
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: socialItems,
          ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
        ],
      ],
    );
  }

  Widget _buildPhoto(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final photoSize = isWide ? 340.0 : 260.0;

    return Container(
      width: photoSize,
      height: photoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.purple, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: _ProfilePhoto(photoUrl: photoUrl),
      ),
    )
        // Part 1: Intro (Fade & Scale) - Happens only once
        .animate()
        .fadeIn(duration: 800.ms, delay: 300.ms)
        .scale(begin: const Offset(0.8, 0.8))
        // Part 2: Fixed Floating - Constant up and down
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -15,
          duration: 2.seconds,
          curve: Curves.easeInOut,
        );
  }
}

class _ProfilePhoto extends StatefulWidget {
  final String photoUrl;

  const _ProfilePhoto({required this.photoUrl});

  @override
  State<_ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<_ProfilePhoto> {
  late List<String> _candidateUrls;
  int _currentIndex = 0;
  bool _scheduledRetry = false;

  @override
  void initState() {
    super.initState();
    _resetCandidates();
  }

  @override
  void didUpdateWidget(covariant _ProfilePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) {
      _resetCandidates();
    }
  }

  void _resetCandidates() {
    _candidateUrls = buildDriveImageCandidates(widget.photoUrl);
    _currentIndex = 0;
    _scheduledRetry = false;
  }

  void _tryNextCandidate() {
    if (_scheduledRetry || _currentIndex >= _candidateUrls.length - 1) return;

    _scheduledRetry = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _currentIndex++;
        _scheduledRetry = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_candidateUrls.isEmpty) {
      return _buildPlaceholderPhoto();
    }

    final imageUrl = _candidateUrls[_currentIndex];

    return CachedNetworkImage(
      key: ValueKey(imageUrl),
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.purple,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) {
        _tryNextCandidate();
        return _currentIndex < _candidateUrls.length - 1
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.purple,
                  strokeWidth: 2,
                ),
              )
            : _buildPlaceholderPhoto();
      },
    );
  }
}

Widget _buildPlaceholderPhoto() {
  return Container(
    color: AppColors.darkCard,
    child: const Icon(
      Icons.person_rounded,
      size: 100,
      color: AppColors.purple,
    ),
  );
}
