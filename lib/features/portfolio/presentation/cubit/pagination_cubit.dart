import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaginationState<T> extends Equatable {
  final List<T> items;
  final int currentPage;
  final int itemsPerPage;

  const PaginationState({
    required this.items,
    required this.currentPage,
    required this.itemsPerPage,
  });

  int get totalPages =>
      items.isEmpty ? 0 : (items.length / itemsPerPage).ceil();

  bool get canGoPrevious => currentPage > 0;

  bool get canGoNext => totalPages > 0 && currentPage < totalPages - 1;

  List<T> get visibleItems {
    if (items.isEmpty) return const [];

    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, items.length);
    return items.sublist(start, end);
  }

  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  @override
  List<Object?> get props => [items, currentPage, itemsPerPage];
}

class PaginationCubit<T> extends Cubit<PaginationState<T>> {
  PaginationCubit({
    required List<T> items,
    int itemsPerPage = 3,
  }) : super(
          PaginationState<T>(
            items: List<T>.unmodifiable(items),
            currentPage: 0,
            itemsPerPage: itemsPerPage,
          ),
        );

  void updateItems(List<T> items) {
    final normalizedItems = List<T>.unmodifiable(items);
    final maxPageIndex = normalizedItems.isEmpty
        ? 0
        : ((normalizedItems.length - 1) / state.itemsPerPage).floor();
    final nextPage = state.currentPage.clamp(0, maxPageIndex);

    emit(
      state.copyWith(
        items: normalizedItems,
        currentPage: nextPage,
      ),
    );
  }

  void nextPage() {
    if (!state.canGoNext) return;
    emit(state.copyWith(currentPage: state.currentPage + 1));
  }

  void previousPage() {
    if (!state.canGoPrevious) return;
    emit(state.copyWith(currentPage: state.currentPage - 1));
  }
}
