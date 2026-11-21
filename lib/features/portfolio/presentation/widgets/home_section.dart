import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/net_image.dart';
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
        // On phones the content sets the height; no forced empty space.
        minHeight: isWide ? MediaQuery.of(context).size.height * 0.7 : 0,
      ),
      padding: EdgeInsets.only(top: isWide ? 0 : 28, bottom: isWide ? 0 : 8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 700 ? 0 : 60,
        ),
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
          url: 'mailto:${email.trim()}',
          tooltip: 'Email',
        ),
    ];

    // Phones: centre everything under the photo. Laptop: unchanged.
    final centered = MediaQuery.sizeOf(context).width <= 800;
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    final wrapAlign = centered ? WrapAlignment.center : WrapAlignment.start;
    final screenW = MediaQuery.sizeOf(context).width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
          textAlign: textAlign,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.purple,
                fontSize: screenW < 600 ? 40 : (centered ? 48 : null),
                height: 1.15,
              ),
        ).animate(delay: 100.ms).fadeIn(duration: 600.ms).slideX(begin: -0.2),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: textAlign,
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
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
        ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: wrapAlign,
          children: [
            ElevatedButton(
              onPressed: onViewProjects,
              child: const Text(AppStrings.viewProjects),
            ),
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
            alignment: wrapAlign,
            children: socialItems,
          ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
        ],
      ],
    );
  }

  Widget _buildPhoto(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final screenW = MediaQuery.sizeOf(context).width;
    final photoSize = isWide ? 340.0 : (screenW < 400 ? 210.0 : 250.0);

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

    return NetImage(
      url: imageUrl,
      fit: BoxFit.cover,
      loading: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.purple,
          strokeWidth: 2,
        ),
      ),
      error: (context) {
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
