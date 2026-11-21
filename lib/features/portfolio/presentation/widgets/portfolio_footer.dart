import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Small footer in the portfolio's own style: thin divider + credit line.
class PortfolioFooter extends StatelessWidget {
  final String name;

  const PortfolioFooter({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final owner = name.trim().isEmpty ? 'YA' : name.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : AppColors.purple)
                .withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: '© ${DateTime.now().year} $owner · Built with '),
          const TextSpan(
            text: 'Flutter',
            style: TextStyle(
              color: AppColors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
