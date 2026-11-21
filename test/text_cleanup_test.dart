import 'package:flutter_test/flutter_test.dart';
import 'package:md_portfolio/features/portfolio/data/models/portfolio_models.dart';

/// Text coming from Firestore is cleaned up when it's read: stray line breaks
/// inside sentences and extra spaces go away, real paragraphs stay.
void main() {
  test('line breaks inside a sentence become spaces', () {
    final p = ProjectModel.fromFirestore({
      'title': '  Event App ',
      'description': 'Event management app with real-time features. \n'
          'Supports Firebase Auth, and event creation/editing. Includes favorites, \n'
          'profile screen, and full localization.',
      'tags': [' Flutter ', '', 'Dart'],
    }, 'id');

    expect(p.title, 'Event App');
    expect(
      p.description,
      'Event management app with real-time features. Supports Firebase Auth, '
      'and event creation/editing. Includes favorites, profile screen, and '
      'full localization.',
    );
    expect(p.tags, ['Flutter', 'Dart']);
  });

  test('blank lines are kept as paragraph breaks', () {
    final e = ExperienceModel.fromFirestore({
      'description': 'First paragraph\ncontinues here.\n\nSecond paragraph.',
    }, 'id');
    expect(e.description, 'First paragraph continues here.\n\nSecond paragraph.');
  });

  test('titles with stray spaces are trimmed', () {
    final c = CertificateModel.fromFirestore(
        {'title': ' Flutter Bootcamp', 'issuer': 'Elevate', 'date': 'Feb 2026'},
        'id');
    expect(c.title, 'Flutter Bootcamp');
  });

  test('missing fields become empty strings', () {
    final o = CustomerOpinionModel.fromFirestore({'rating': 5}, 'id');
    expect(o.comment, '');
    expect(o.customerName, '');
  });
}
