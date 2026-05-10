import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_constants.dart';

class ContactInfo extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String text;
  final VoidCallback onTap;

  const ContactInfo({
    super.key,
    this.icon,
    this.svgPath,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          svgPath != null
              ? SvgPicture.asset(
                  svgPath!,
                  width: 18,
                  height: 18,
                )
              : Icon(icon, color: AppColors.cyan, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
