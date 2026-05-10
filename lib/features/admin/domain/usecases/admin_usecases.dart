import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../repositories/admin_repository.dart';

class UpdateProfileUseCase {
  final AdminRepository _repo;
  UpdateProfileUseCase(this._repo);
  Future<void> call(ProfileEntity profile) => _repo.updateProfile(profile);
}

class AddSkillUseCase {
  final AdminRepository _repo;
  AddSkillUseCase(this._repo);
  Future<void> call(SkillEntity skill) => _repo.addSkill(skill);
}

class DeleteSkillUseCase {
  final AdminRepository _repo;
  DeleteSkillUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteSkill(id);
}

class AddProjectUseCase {
  final AdminRepository _repo;
  AddProjectUseCase(this._repo);
  Future<void> call(ProjectEntity project) => _repo.addProject(project);
}

class UpdateProjectUseCase {
  final AdminRepository _repo;
  UpdateProjectUseCase(this._repo);
  Future<void> call(ProjectEntity project) => _repo.updateProject(project);
}

class DeleteProjectUseCase {
  final AdminRepository _repo;
  DeleteProjectUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteProject(id);
}

class AddCertificateUseCase {
  final AdminRepository _repo;
  AddCertificateUseCase(this._repo);
  Future<void> call(CertificateEntity cert) => _repo.addCertificate(cert);
}

class DeleteCertificateUseCase {
  final AdminRepository _repo;
  DeleteCertificateUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteCertificate(id);
}

class AddOpinionUseCase {
  final AdminRepository _repo;
  AddOpinionUseCase(this._repo);
  Future<void> call(CustomerOpinionEntity opinion) => _repo.addOpinion(opinion);
}

class DeleteOpinionUseCase {
  final AdminRepository _repo;
  DeleteOpinionUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteOpinion(id);
}

class AddExperienceUseCase {
  final AdminRepository _repo;
  AddExperienceUseCase(this._repo);
  Future<void> call(ExperienceEntity experience) => _repo.addExperience(experience);
}

class UpdateExperienceUseCase {
  final AdminRepository _repo;
  UpdateExperienceUseCase(this._repo);
  Future<void> call(ExperienceEntity experience) => _repo.updateExperience(experience);
}

class DeleteExperienceUseCase {
  final AdminRepository _repo;
  DeleteExperienceUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteExperience(id);
}
