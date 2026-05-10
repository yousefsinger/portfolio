import 'package:flutter_test/flutter_test.dart';
import 'package:md_portfolio/features/portfolio/presentation/cubit/pagination_cubit.dart';

void main() {
  group('PaginationCubit', () {
    test('shows 3 items per page and moves between pages safely', () {
      final cubit = PaginationCubit<int>(items: [1, 2, 3, 4, 5, 6, 7]);

      expect(cubit.state.visibleItems, [1, 2, 3]);
      expect(cubit.state.totalPages, 3);
      expect(cubit.state.canGoPrevious, isFalse);
      expect(cubit.state.canGoNext, isTrue);

      cubit.nextPage();
      expect(cubit.state.visibleItems, [4, 5, 6]);
      expect(cubit.state.canGoPrevious, isTrue);
      expect(cubit.state.canGoNext, isTrue);

      cubit.nextPage();
      expect(cubit.state.visibleItems, [7]);
      expect(cubit.state.canGoNext, isFalse);

      cubit.nextPage();
      expect(cubit.state.visibleItems, [7]);

      cubit.previousPage();
      expect(cubit.state.visibleItems, [4, 5, 6]);

      cubit.close();
    });

    test('clamps the active page when items shrink', () {
      final cubit = PaginationCubit<int>(items: [1, 2, 3, 4, 5, 6, 7]);

      cubit.nextPage();
      cubit.nextPage();
      expect(cubit.state.currentPage, 2);

      cubit.updateItems([1, 2, 3, 4]);

      expect(cubit.state.currentPage, 1);
      expect(cubit.state.visibleItems, [4]);

      cubit.close();
    });
  });
}
