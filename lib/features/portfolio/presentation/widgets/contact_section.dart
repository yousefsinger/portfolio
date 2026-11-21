import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/email_launcher.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../../core/utils/section_title.dart';
import 'contact_form.dart';
import 'contact_info.dart';

class ContactSection extends StatelessWidget {
  final String email;
  final String phone;

  const ContactSection({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final hasEmail = email.trim().isNotEmpty;
    final hasPhone = phone.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 700 ? 0 : 60,
        vertical: MediaQuery.sizeOf(context).width < 700 ? 24 : AppSizes.sectionPadding,
      ),
      child: Column(
        children: [
          const SectionTitle(title: AppStrings.contactTitle),
          SizedBox(height: MediaQuery.sizeOf(context).width < 700 ? 28 : 48),
          SizedBox(
            width: 600,
            child: Column(
              children: [
                if (hasEmail || hasPhone) ...[
                  GradientBorderCard(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 40,
                      runSpacing: 14,
                      children: [
                        if (hasEmail)
                          ContactInfo(
                            svgPath: 'assets/icons/gmailicon.svg',
                            text: email,
                            onTap: () => launchEmail(email),
                          ),
                        if (hasEmail && hasPhone) const SizedBox(width: 40),
                        if (hasPhone)
                          ContactInfo(
                            icon: Icons.phone_outlined,
                            text: phone,
                            onTap: () async {
                              final Uri phoneUri = Uri(
                                scheme: 'tel',
                                path: phone.trim(),
                              );
                              if (await canLaunchUrl(phoneUri)) {
                                await launchUrl(phoneUri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 24),
                ],
                // Send message card
                const ContactForm()
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
