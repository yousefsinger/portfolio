import '../../../portfolio/domain/entities/portfolio_entities.dart';

abstract class AdminRepository {
  Future<void> updateProfile(ProfileEntity profile);
  Future<void> addSkill(SkillEntity skill);
  Future<void> deleteSkill(String id);
  Future<void> addProject(ProjectEntity project);
  Future<void> updateProject(ProjectEntity project);
  Future<void> deleteProject(String id);
  Future<void> addCertificate(CertificateEntity certificate);
  Future<void> updateCertificate(CertificateEntity certificate);
  Future<void> deleteCertificate(String id);

  Future<void> addExperience(ExperienceEntity experience);
  Future<void> updateExperience(ExperienceEntity experience);
  Future<void> deleteExperience(String id);

  Future<void> addOpinion(CustomerOpinionEntity opinion);
  Future<void> deleteOpinion(String id);
}
