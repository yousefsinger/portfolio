import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme
  static const Color darkBg = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkCardHover = Color(0xFF1E2A45);

  // Light Theme
  static const Color lightBg = Color(0xFFF0F0F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEEEEF8);
  static const Color lightCardHover = Color(0xFFE0E0F0);

  // Accent
  static const Color purple = Color(0xFF7C3AED);
  static const Color cyan = Color(0xFF06B6D4);

  // Text
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0C8);
  static const Color textPrimaryLight = Color(0xFF0D0D1A);
  static const Color textSecondaryLight = Color(0xFF4A4A6A);

}

class AppStrings {
  // Admin Code
  static const String adminCode = '1362003';
  // EmailJS
  static const String serviceId = 'service_g49788l';
  static const String templateId = 'template_x1w1d44';
  static const String publicKey = 'g1n7so2_FgyRRx4dM';
  static const String endpoint = 'https://api.emailjs.com/api/v1.0/email/send';

  // Nav
  static const String home = 'Home';
  static const String about = 'About';
  static const String skills = 'Skills';
  static const String projects = 'Projects';
  static const String certificates = 'Certificates';
  static const String opinions = 'Opinions';
  static const String contact = 'Contact';

  // Home
  static const String greeting = "Hello, I'm";
  static const String viewProjects = 'View Projects';
  static const String downloadCV = 'Download CV';

  // About
  static const String aboutTitle = 'About Me';

  // Contact
  static const String contactTitle = 'Contact Me';

  // Opinions
  static const String opinionsTitle = 'Customer Opinions';

  // Role Selection
  static const String chooseRole = 'Welcome';
  static const String chooseRoleSubtitle = 'How would you like to continue?';
  static const String visitor = 'Visitor';
  static const String admin = 'Admin';
  static const String visitorDesc = 'Browse the portfolio';
  static const String adminDesc = 'Manage content';

  // Admin
  static const String enterCode = 'Enter Admin Code';
  static const String invalidCode = 'Invalid code. Please try again.';
  static const String editMode = 'Edit Mode';
  static const String viewMode = 'View Portfolio';
}

class AppSizes {
  static const double navHeight = 70.0;
  static const double sectionPadding = 50.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 30.0;
}
