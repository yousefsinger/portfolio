import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/net_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../domain/entities/portfolio_entities.dart';

class ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  final int delay;

  const ProjectCard({super.key, required this.project, required this.delay});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    if (widget.project.imageUrls.length > 1) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= widget.project.imageUrls.length) {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return GradientBorderCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.cardRadius),
              topRight: Radius.circular(AppSizes.cardRadius),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: project.imageUrls.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: project.imageUrls.length,
                      onPageChanged: (index) => _currentPage = index,
                      itemBuilder: (context, index) {
                        return NetImage(
                          url: project.imageUrls[index],
                          fit: BoxFit.cover,
                          loading: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.purple,
                              strokeWidth: 2,
                            ),
                          ),
                          error: (context) => _imagePlaceholder(),
                        );
                      },
                    )
                  : _imagePlaceholder(),
            ),
          ),
          // Fills the card height (cards in a row share one height), so the
          // links sit at the bottom of every card.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  if (_links.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final link in _links)
                          TextButton.icon(
                            onPressed: () => _open(link.url),
                            icon: Icon(link.icon, size: 16),
                            label: Text(link.label),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.purple,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  /// Only the links the project actually has (all of them are optional).
  List<({String label, IconData icon, String url})> get _links {
    final p = widget.project;
    return [
      if (p.githubUrl?.isNotEmpty ?? false)
        (label: 'View Code', icon: Icons.code_rounded, url: p.githubUrl!),
      if (p.playStoreUrl?.isNotEmpty ?? false)
        (label: 'Google Play', icon: Icons.shop_rounded, url: p.playStoreUrl!),
      if (p.appStoreUrl?.isNotEmpty ?? false)
        (label: 'App Store', icon: Icons.apple, url: p.appStoreUrl!),
    ];
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.darkCard,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.purple,
        ),
      ),
    );
  }
}
