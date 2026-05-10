import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/portfolio_entities.dart';
import '../../domain/usecases/get_portfolio_data_usecase.dart';
import '../../domain/usecases/watch_portfolio_data_usecase.dart';
import '../../domain/usecases/submit_opinion_usecase.dart';

// States
abstract class PortfolioState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final PortfolioDataEntity data;
  PortfolioLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class PortfolioError extends PortfolioState {
  final String message;
  PortfolioError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class PortfolioCubit extends Cubit<PortfolioState> {
  final GetPortfolioDataUseCase _getPortfolioData;
  final WatchPortfolioDataUseCase _watchPortfolioData;
  final SubmitOpinionUseCase _submitOpinionUseCase;
  StreamSubscription? _subscription;

  PortfolioCubit(
    this._getPortfolioData,
    this._watchPortfolioData,
    this._submitOpinionUseCase,
  ) : super(PortfolioInitial());

  Future<void> loadPortfolio() async {
    emit(PortfolioLoading());
    // Initial fetch
    try {
      final data = await _getPortfolioData.call();
      emit(PortfolioLoaded(data));
      // Then start watching
      _startWatching();
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  Future<void> submitOpinion(CustomerOpinionEntity opinion) async {
    try {
      await _submitOpinionUseCase.call(opinion);
    } catch (e) {
      // Depending on requirement, we can emit an error or just show a log.
      // We don't want to break the loaded state just for a failed submission,
      // but maybe emit a brief error if we had a more complex state.
      // For now, we'll let it throw to handle it in UI or just ignore.
      throw Exception('Failed to add opinion: $e');
    }
  }

  void _startWatching() {
    _subscription?.cancel();
    _subscription = _watchPortfolioData.call().listen(
      (data) {
        if (!isClosed) emit(PortfolioLoaded(data));
      },
      onError: (e) {
        if (!isClosed) emit(PortfolioError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
