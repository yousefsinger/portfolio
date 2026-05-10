import '../entities/portfolio_entities.dart';
import '../repositories/portfolio_repository.dart';

class GetPortfolioDataUseCase {
  final PortfolioRepository _repository;

  GetPortfolioDataUseCase(this._repository);

  Future<PortfolioDataEntity> call() => _repository.getPortfolioData();

  Stream<PortfolioDataEntity> watch() => _repository.watchPortfolioData();
}
