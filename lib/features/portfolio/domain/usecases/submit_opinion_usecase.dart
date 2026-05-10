import '../entities/portfolio_entities.dart';
import '../repositories/portfolio_repository.dart';

class SubmitOpinionUseCase {
  final PortfolioRepository repository;

  SubmitOpinionUseCase(this.repository);

  Future<void> call(CustomerOpinionEntity opinion) {
    return repository.addOpinion(opinion);
  }
}

