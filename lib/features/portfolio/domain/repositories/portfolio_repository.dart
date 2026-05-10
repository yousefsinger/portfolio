import '../entities/portfolio_entities.dart';

abstract class PortfolioRepository {
  Future<PortfolioDataEntity> getPortfolioData();
  Stream<PortfolioDataEntity> watchPortfolioData();
  Future<void> addOpinion(CustomerOpinionEntity opinion);
}
