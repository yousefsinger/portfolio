import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// Opens an email compose screen addressed to [email].
///
/// On web, `mailto:` silently does nothing when the visitor has no desktop
/// mail client configured, so we open Gmail's web compose page instead.
/// On mobile/desktop apps we use `mailto:` and fall back to Gmail web.
Future<void> launchEmail(String email) async {
  final address = email.trim().replaceFirst(RegExp(r'^mailto:'), '');
  if (address.isEmpty) return;

  final gmailUri = Uri.https('mail.google.com', '/mail/', {
    'view': 'cm',
    'fs': '1',
    'to': address,
  });

  if (kIsWeb) {
    await launchUrl(gmailUri, webOnlyWindowName: '_blank');
    return;
  }

  final mailtoUri = Uri(scheme: 'mailto', path: address);
  final opened = await launchUrl(mailtoUri,
          mode: LaunchMode.externalApplication)
      .catchError((_) => false);
  if (!opened) {
    await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
  }
}
