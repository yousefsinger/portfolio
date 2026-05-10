import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/portfolio_entities.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../models/portfolio_models.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final FirebaseFirestore _firestore;

  PortfolioRepositoryImpl(this._firestore);

  // Collection references
  CollectionReference get _portfolioCol => _firestore.collection('portfolio');
  DocumentReference get _profileDoc => _portfolioCol.doc('profile');
  CollectionReference get _skillsCol =>
      _portfolioCol.doc('data').collection('skills');
  CollectionReference get _projectsCol =>
      _portfolioCol.doc('data').collection('projects');
  CollectionReference get _certificatesCol =>
      _portfolioCol.doc('data').collection('certificates');
  CollectionReference get _opinionsCol =>
      _portfolioCol.doc('data').collection('opinions');
  CollectionReference get _experiencesCol =>
      _portfolioCol.doc('data').collection('experiences');

  @override
  Future<PortfolioDataEntity> getPortfolioData() async {
    final results = await Future.wait([
      _profileDoc.get(),
      _skillsCol.get(),
      _projectsCol.get(),
      _certificatesCol.get(),
      _opinionsCol.get(),
      _experiencesCol.get(),
    ]);

    final profileDoc = results[0] as DocumentSnapshot;
    final skillsDocs = results[1] as QuerySnapshot;
    final projectsDocs = results[2] as QuerySnapshot;
    final certsDocs = results[3] as QuerySnapshot;
    final opinionsDocs = results[4] as QuerySnapshot;
    final experiencesDocs = results[5] as QuerySnapshot;

    final profileData = profileDoc.data();
    final profile = profileData is Map<String, dynamic>
        ? ProfileModel.fromFirestore(profileData)
        : const ProfileModel(
            name: '',
            title: '',
            subtitle: '',
            bio: '',
            photoUrl: '',
            email: '',
            phone: '',
            github: '',
            linkedin: '',
            cvUrl: '',
            badges: [],
          );

    final skills = skillsDocs.docs.map((doc) {
      return SkillModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    final projects = projectsDocs.docs.map((doc) {
      return ProjectModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    final certificates = certsDocs.docs.map((doc) {
      return CertificateModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    final opinions = opinionsDocs.docs.map((doc) {
      return CustomerOpinionModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    final experiences = experiencesDocs.docs.map((doc) {
      return ExperienceModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    return PortfolioDataEntity(
      profile: profile,
      skills: _deduplicateSkills(skills),
      projects: _deduplicateProjects(projects),
      certificates: _deduplicateCertificates(certificates),
      opinions: _deduplicateOpinions(opinions),
      experiences: _deduplicateExperiences(experiences),
    );
  }

  List<SkillEntity> _deduplicateSkills(List<SkillModel> list) {
    final seen = <String>{};
    return list.where((item) => seen.add(item.name)).toList();
  }

  List<ProjectEntity> _deduplicateProjects(List<ProjectModel> list) {
    final seen = <String>{};
    return list.where((item) => seen.add(item.title)).toList();
  }

  List<CertificateEntity> _deduplicateCertificates(
      List<CertificateModel> list) {
    final seen = <String>{};
    return list.where((item) => seen.add(item.title)).toList();
  }

  List<CustomerOpinionEntity> _deduplicateOpinions(
      List<CustomerOpinionModel> list) {
    final seen = <String>{};
    return list
        .where((item) => seen.add('${item.customerName}|${item.comment}'))
        .toList();
  }

  List<ExperienceEntity> _deduplicateExperiences(List<ExperienceModel> list) {
    final seen = <String>{};
    return list.where((item) => seen.add('${item.company}|${item.role}')).toList();
  }

  @override
  Stream<PortfolioDataEntity> watchPortfolioData() {
    final controller = StreamController<PortfolioDataEntity>();

    void update() async {
      try {
        final data = await getPortfolioData();
        if (!controller.isClosed) controller.add(data);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    final pSub = _profileDoc.snapshots().listen((_) => update());
    final skillsSub = _skillsCol.snapshots().listen((_) => update());
    final projSub = _projectsCol.snapshots().listen((_) => update());
    final certSub = _certificatesCol.snapshots().listen((_) => update());
    final opinionsSub = _opinionsCol.snapshots().listen((_) => update());
    final experiencesSub = _experiencesCol.snapshots().listen((_) => update());

    controller.onCancel = () {
      pSub.cancel();
      skillsSub.cancel();
      projSub.cancel();
      certSub.cancel();
      opinionsSub.cancel();
      experiencesSub.cancel();
    };

    // Initial trigger
    update();

    return controller.stream;
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
}
