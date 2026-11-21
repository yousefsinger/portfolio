import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_portfolio/features/admin/domain/repositories/admin_repository.dart';
import 'package:md_portfolio/features/admin/domain/usecases/admin_usecases.dart';
import 'package:md_portfolio/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:md_portfolio/features/admin/presentation/widgets/projects_tab.dart';
import 'package:md_portfolio/features/portfolio/data/models/portfolio_models.dart';
import 'package:md_portfolio/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:md_portfolio/features/portfolio/domain/entities/portfolio_entities.dart';

ProjectEntity _project(String id, {int? order, DateTime? createdAt}) =>
    ProjectEntity(
      id: id,
      title: 'Project $id',
      description: 'Description',
      imageUrls: const [],
      tags: const [],
      order: order,
      createdAt: createdAt,
    );

/// Records reorder calls; every other write is a no-op.
class _FakeAdminRepository implements AdminRepository {
  final reorders = <List<String>>[];

  @override
  Future<void> reorderProjects(List<String> idsInOrder) async =>
      reorders.add(List.of(idsInOrder));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

AdminCubit _cubit(AdminRepository r) => AdminCubit(
      UpdateProfileUseCase(r),
      AddSkillUseCase(r),
      AddProjectUseCase(r),
      UpdateProjectUseCase(r),
      AddCertificateUseCase(r),
      DeleteSkillUseCase(r),
      DeleteProjectUseCase(r),
      DeleteCertificateUseCase(r),
      AddOpinionUseCase(r),
      DeleteOpinionUseCase(r),
      AddExperienceUseCase(r),
      UpdateExperienceUseCase(r),
      DeleteExperienceUseCase(r),
      ReorderProjectsUseCase(r),
    );

void main() {
  group('portfolio order', () {
    test('projects with an order come first, lowest number first', () {
      final list = [
        _project('new', createdAt: DateTime(2026, 5)),
        _project('second', order: 1),
        _project('old', createdAt: DateTime(2025, 1)),
        _project('first', order: 0),
      ]..sort(compareProjects);

      expect(list.map((p) => p.id), ['first', 'second', 'new', 'old']);
    });

    test('without any order, newest comes first (old behaviour)', () {
      final list = [
        _project('a', createdAt: DateTime(2025, 1)),
        _project('b', createdAt: DateTime(2026, 1)),
      ]..sort(compareProjects);
      expect(list.map((p) => p.id), ['b', 'a']);
    });

    test('order is read from Firestore and only written when set', () {
      expect(ProjectModel.fromFirestore({'order': 3}, 'x').order, 3);
      expect(ProjectModel.fromFirestore({'order': 2.0}, 'x').order, 2);
      expect(ProjectModel.fromFirestore({}, 'x').order, isNull);

      const unordered = ProjectModel(
          id: 'x', title: '', description: '', imageUrls: [], tags: []);
      expect(unordered.toFirestore().containsKey('order'), isFalse);
    });
  });

  group('admin projects tab', () {
    Future<_FakeAdminRepository> pumpTab(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final repo = _FakeAdminRepository();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => _cubit(repo),
            child: ProjectsTab(projects: [
              _project('a'),
              _project('b'),
              _project('c'),
            ]),
          ),
        ),
      ));
      return repo;
    }

    testWidgets('"Move up" swaps a project with the one above',
        (tester) async {
      final repo = await pumpTab(tester);

      await tester.tap(find.byTooltip('Move up').at(2)); // project c
      await tester.pump();

      expect(repo.reorders.single, ['a', 'c', 'b']);
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('fits on a small phone without overflow', (tester) async {
      await pumpTab(tester);
      tester.view.physicalSize = const Size(360, 780);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Move up'), findsNWidgets(3));
    });

    testWidgets('"Move to top" puts a project first', (tester) async {
      final repo = await pumpTab(tester);

      await tester.tap(find.byTooltip('Move to top').at(2)); // project c
      await tester.pump();

      expect(repo.reorders.single, ['c', 'a', 'b']);
    });
  });
}
