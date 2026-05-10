import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../../domain/usecases/admin_usecases.dart';

// ── States ──────────────────────────────────────────────────────────────────
abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminSuccess extends AdminState {
  final String message;
  AdminSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ────────────────────────────────────────────────────────────────────
class AdminCubit extends Cubit<AdminState> {
  final UpdateProfileUseCase _updateProfile;
  final AddSkillUseCase _addSkill;
  final AddProjectUseCase _addProject;
  final UpdateProjectUseCase _updateProject;
  final AddCertificateUseCase _addCertificate;
  final DeleteSkillUseCase _deleteSkill;
  final DeleteProjectUseCase _deleteProject;
  final DeleteCertificateUseCase _deleteCertificate;
  final AddOpinionUseCase _addOpinion;
  final DeleteOpinionUseCase _deleteOpinion;

  final AddExperienceUseCase _addExperience;
  final UpdateExperienceUseCase _updateExperience;
  final DeleteExperienceUseCase _deleteExperience;

  AdminCubit(
    this._updateProfile,
    this._addSkill,
    this._addProject,
    this._updateProject,
    this._addCertificate,
    this._deleteSkill,
    this._deleteProject,
    this._deleteCertificate,
    this._addOpinion,
    this._deleteOpinion,
    this._addExperience,
    this._updateExperience,
    this._deleteExperience,
  ) : super(AdminInitial());

  Future<void> updateProfile(ProfileEntity profile) async {
    emit(AdminLoading());
    try {
      await _updateProfile(profile);
      emit(AdminSuccess('Profile updated successfully!'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addSkill(SkillEntity skill) async {
    emit(AdminLoading());
    try {
      await _addSkill(skill);
      emit(AdminSuccess('Skill added successfully!'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> deleteSkill(String id) async {
    emit(AdminLoading());
    try {
      await _deleteSkill(id);
      emit(AdminSuccess('Skill deleted.'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addProject(ProjectEntity project) async {
    emit(AdminLoading());
    try {
      await _addProject(project);
      emit(AdminSuccess('Project added successfully!'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> updateProject(ProjectEntity project) async {
    emit(AdminLoading());
    try {
      await _updateProject(project);
      emit(AdminSuccess('Project updated successfully!'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> deleteProject(String id) async {
    emit(AdminLoading());
    try {
      await _deleteProject(id);
      emit(AdminSuccess('Project deleted.'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addCertificate(CertificateEntity certificate) async {
    emit(AdminLoading());
    try {
      await _addCertificate(certificate);
      emit(AdminSuccess('Certificate added successfully!'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> deleteCertificate(String id) async {
    emit(AdminLoading());
    try {
      await _deleteCertificate(id);
      emit(AdminSuccess('Certificate deleted.'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addOpinion(CustomerOpinionEntity opinion) async {
    emit(AdminLoading());
    try {
      await _addOpinion(opinion);
      emit(AdminSuccess('Opinion added successfully!'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> deleteOpinion(String id) async {
    emit(AdminLoading());
    try {
      await _deleteOpinion(id);
      emit(AdminSuccess('Opinion deleted.'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addExperience(ExperienceEntity experience) async {
    emit(AdminLoading());
    try {
      await _addExperience(experience);
      emit(AdminSuccess('Experience added successfully!'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> updateExperience(ExperienceEntity experience) async {
    emit(AdminLoading());
    try {
      await _updateExperience(experience);
      emit(AdminSuccess('Experience updated successfully!'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> deleteExperience(String id) async {
    emit(AdminLoading());
    try {
      await _deleteExperience(id);
      emit(AdminSuccess('Experience deleted.'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
