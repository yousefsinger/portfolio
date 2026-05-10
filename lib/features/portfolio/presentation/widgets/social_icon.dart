import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';

class SocialIcon extends StatefulWidget {
  final IconData? icon;
  final String? svgPath;
  final String url;
  final String tooltip;

  const SocialIcon({
    super.key,
    this.icon,
    this.svgPath,
    required this.url,
    required this.tooltip,
  });

  @override
  State<SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<SocialIcon> {
  late final ValueNotifier<bool> _hoveredNotifier;

  @override
  void initState() {
    super.initState();
    _hoveredNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _hoveredNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoveredNotifier.value = true,
      onExit: (_) => _hoveredNotifier.value = false,
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: () => launchUrl(Uri.parse(widget.url)),
          child: ValueListenableBuilder<bool>(
            valueListenable: _hoveredNotifier,
            builder: (context, hovered, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hovered
                      ? AppColors.purple.withValues(alpha: 0.15)
                      : Colors.transparent,
                ),
                child: widget.svgPath != null
                    ? SvgPicture.asset(
                        widget.svgPath!,
                        width: 24,
                        height: 24,
                      )
                    : Icon(
                        widget.icon,
                        color: hovered ? AppColors.purple : Colors.white70,
                        size: 24,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
