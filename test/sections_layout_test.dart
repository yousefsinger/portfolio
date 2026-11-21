import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_portfolio/features/portfolio/domain/entities/portfolio_entities.dart';
import 'package:md_portfolio/features/portfolio/presentation/widgets/about_section.dart';
import 'package:md_portfolio/features/portfolio/presentation/widgets/certificates_section.dart';
import 'package:md_portfolio/features/portfolio/presentation/widgets/contact_section.dart';
import 'package:md_portfolio/features/portfolio/presentation/widgets/experience_section.dart';
import 'package:md_portfolio/features/portfolio/presentation/widgets/opinions_section.dart';
import 'package:md_portfolio/features/portfolio/presentation/widgets/projects_section.dart';
import 'package:md_portfolio/features/portfolio/presentation/widgets/skills_section.dart';

/// Renders the portfolio sections at phone, tablet and desktop widths and
/// fails on any layout exception (overflow, unbounded size, intrinsics...).
void main() {
  final projects = List.generate(
    5,
    (i) => ProjectEntity(
      id: 'p$i',
      title: 'Project $i with a fairly long title',
      description: 'Description ' * (i + 3),
      imageUrls: const [],
      tags: const ['Flutter', 'Firebase', 'Bloc', 'Clean Architecture'],
      githubUrl: i.isEven ? 'https://github.com' : null,
    ),
  );
  final certificates = List.generate(
    4,
    (i) => CertificateEntity(
      id: 'c$i',
      title: 'Certificate $i in Mobile Development',
      issuer: 'Some Academy',
      date: '2025',
      credentialUrl: i.isOdd ? 'https://example.com' : null,
    ),
  );
  final experiences = List.generate(
    3,
    (i) => ExperienceEntity(
      id: 'e$i',
      company: 'Company $i',
      role: 'Flutter Developer',
      startDate: 'Jan 2024',
      endDate: 'Present',
      description: 'Built things. ' * (i * 4 + 2),
    ),
  );
  final opinions = List.generate(
    6,
    (i) => CustomerOpinionEntity(
      id: 'o$i',
      customerName: 'Client $i',
      customerRole: 'CEO',
      company: 'Startup',
      comment: 'Great work! ' * (i * 3 + 2),
      rating: 5,
    ),
  );
  final skills =
      List.generate(13, (i) => SkillEntity(id: 's$i', name: 'Skill $i'));

  // Mirrors the page: 30px side padding on small screens.
  Widget page(double width) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width > 1000 ? 100 : 30),
          child: Column(
            children: [
              AboutSection(bio: 'Bio ' * 60, badges: const ['A', 'B', 'C']),
              SkillsSection(skills: skills),
              ProjectsSection(projects: projects),
              ExperienceSection(experiences: experiences),
              CertificatesSection(certificates: certificates),
              OpinionsSection(opinions: opinions),
              const ContactSection(
                email: 'someone.with.long.email@example.com',
                phone: '+20 100 000 0000',
              ),
            ],
          ),
        ),
      );

  for (final size in const [Size(360, 780), Size(820, 1180), Size(1440, 900)]) {
    testWidgets('sections lay out at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: page(size.width)),
      ));
      await tester.pump(const Duration(seconds: 2));
      for (int i = 0; i < 10; i++) {
        await tester.drag(
            find.byType(SingleChildScrollView).first, const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 800));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
