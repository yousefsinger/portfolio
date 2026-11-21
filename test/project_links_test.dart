import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_portfolio/features/portfolio/data/models/portfolio_models.dart';
import 'package:md_portfolio/features/portfolio/domain/entities/portfolio_entities.dart';
import 'package:md_portfolio/features/portfolio/presentation/widgets/project_card.dart';

Future<void> _pumpCard(WidgetTester tester, ProjectEntity project) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 340, child: ProjectCard(project: project, delay: 0)),
    ),
  ));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  test('store links are optional and blank ones become null', () {
    final p = ProjectModel.fromFirestore({
      'githubUrl': 'https://github.com/x',
      'playStoreUrl': '   ',
      'appStoreUrl': 'https://apps.apple.com/app/id1',
    }, 'id');
    expect(p.playStoreUrl, isNull);
    expect(p.appStoreUrl, 'https://apps.apple.com/app/id1');
    expect(p.toFirestore()['appStoreUrl'], 'https://apps.apple.com/app/id1');
  });

  testWidgets('card shows only the links a project has', (tester) async {
    await _pumpCard(
      tester,
      const ProjectEntity(
        id: '1',
        title: 'App',
        description: 'd',
        imageUrls: [],
        tags: [],
        githubUrl: 'https://github.com/x',
        playStoreUrl: 'https://play.google.com/store/apps/details?id=x',
        appStoreUrl: 'https://apps.apple.com/app/id1',
      ),
    );
    expect(find.text('View Code'), findsOneWidget);
    expect(find.text('Google Play'), findsOneWidget);
    expect(find.text('App Store'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no store buttons when the links are missing', (tester) async {
    await _pumpCard(
      tester,
      const ProjectEntity(
        id: '2',
        title: 'App',
        description: 'd',
        imageUrls: [],
        tags: [],
        githubUrl: 'https://github.com/x',
      ),
    );
    expect(find.text('View Code'), findsOneWidget);
    expect(find.text('Google Play'), findsNothing);
    expect(find.text('App Store'), findsNothing);
  });
}
