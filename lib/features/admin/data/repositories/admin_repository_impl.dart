import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../portfolio/data/models/portfolio_models.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepositoryImpl(this._firestore);

  DocumentReference get _profileDoc =>
      _firestore.collection('portfolio').doc('profile');

  CollectionReference get _skillsCol =>
      _firestore.collection('portfolio').doc('data').collection('skills');

  CollectionReference get _projectsCol =>
      _firestore.collection('portfolio').doc('data').collection('projects');

  CollectionReference get _certificatesCol =>
      _firestore.collection('portfolio').doc('data').collection('certificates');

  CollectionReference get _experiencesCol =>
      _firestore.collection('portfolio').doc('data').collection('experiences');

  CollectionReference get _opinionsCol =>
      _firestore.collection('portfolio').doc('data').collection('opinions');

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    await _profileDoc.set(
      ProfileModel(
        name: profile.name,
        title: profile.title,
        subtitle: profile.subtitle,
        bio: profile.bio,
        photoUrl: profile.photoUrl,
        email: profile.email,
        phone: profile.phone,
        github: profile.github,
        linkedin: profile.linkedin,
        cvUrl: profile.cvUrl,
        badges: profile.badges,
      ).toFirestore(),
    );
  }

  @override
  Future<void> addSkill(SkillEntity skill) async {
    await _skillsCol.add(
      SkillModel(
        id: '',
        name: skill.name,
        iconUrl: skill.iconUrl,
        svgContent: skill.svgContent,
      ).toFirestore(),
    );
  }

  @override
  Future<void> deleteSkill(String id) async {
    await _skillsCol.doc(id).delete();
  }

  @override
  Future<void> addProject(ProjectEntity project) async {
    await _projectsCol.add(
      ProjectModel(
        id: '',
        title: project.title,
        description: project.description,
        imageUrl: project.imageUrl,
        tags: project.tags,
        githubUrl: project.githubUrl,
        playStoreUrl: project.playStoreUrl,
      ).toFirestore(),
    );
  }

  @override
  Future<void> updateProject(ProjectEntity project) async {
    await _projectsCol.doc(project.id).update(
          ProjectModel(
            id: project.id,
            title: project.title,
            description: project.description,
            imageUrl: project.imageUrl,
            tags: project.tags,
            githubUrl: project.githubUrl,
            playStoreUrl: project.playStoreUrl,
          ).toFirestore(),
        );
  }

  @override
  Future<void> deleteProject(String id) async {
    await _projectsCol.doc(id).delete();
  }

  @override
  Future<void> addCertificate(CertificateEntity certificate) async {
    await _certificatesCol.add(
      CertificateModel(
        id: '',
        title: certificate.title,
        issuer: certificate.issuer,
        date: certificate.date,
        credentialUrl: certificate.credentialUrl,
      ).toFirestore(),
    );
  }

  @override
  Future<void> updateCertificate(CertificateEntity certificate) async {
    await _certificatesCol.doc(certificate.id).update(
          CertificateModel(
            id: certificate.id,
            title: certificate.title,
            issuer: certificate.issuer,
            date: certificate.date,
            credentialUrl: certificate.credentialUrl,
          ).toFirestore(),
        );
  }

  @override
  Future<void> deleteCertificate(String id) async {
    await _certificatesCol.doc(id).delete();
  }

  @override
  Future<void> addOpinion(CustomerOpinionEntity opinion) async {
    await _opinionsCol.add(
      CustomerOpinionModel(
        id: '',
        customerName: opinion.customerName,
        customerRole: opinion.customerRole,
        company: opinion.company,
        comment: opinion.comment,
        rating: opinion.rating,
      ).toFirestore(),
    );
  }

  @override
  Future<void> deleteOpinion(String id) async {
    await _opinionsCol.doc(id).delete();
  }

  @override
  Future<void> addExperience(ExperienceEntity experience) async {
    await _experiencesCol.add(
      ExperienceModel(
        id: '',
        company: experience.company,
        role: experience.role,
        startDate: experience.startDate,
        endDate: experience.endDate,
        description: experience.description,
      ).toFirestore(),
    );
  }

  @override
  Future<void> updateExperience(ExperienceEntity experience) async {
    await _experiencesCol.doc(experience.id).update(
          ExperienceModel(
            id: experience.id,
            company: experience.company,
            role: experience.role,
            startDate: experience.startDate,
            endDate: experience.endDate,
            description: experience.description,
          ).toFirestore(),
        );
  }

  @override
  Future<void> deleteExperience(String id) async {
    await _experiencesCol.doc(id).delete();
  }
}

