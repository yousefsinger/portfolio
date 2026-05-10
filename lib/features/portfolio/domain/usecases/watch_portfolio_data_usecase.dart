import '../repositories/portfolio_repository.dart';
import '../entities/portfolio_entities.dart';

class WatchPortfolioDataUseCase {
  final PortfolioRepository repository;

  WatchPortfolioDataUseCase(this.repository);

  Stream<PortfolioDataEntity> call() {
    return repository.watchPortfolioData();
  }
}
