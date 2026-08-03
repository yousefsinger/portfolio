import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String title;
  final String subtitle;
  final String bio;
  final String photoUrl;
  final String email;
  final String phone;
  final String github;
  final String linkedin;
  final String cvUrl;
  final List<String> badges;

  const ProfileEntity({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.bio,
    required this.photoUrl,
    required this.email,
    required this.phone,
    required this.github,
    required this.linkedin,
    required this.cvUrl,
    required this.badges,
  });

  @override
  List<Object?> get props => [
        name,
        title,
        subtitle,
        bio,
        photoUrl,
        email,
        phone,
        github,
        linkedin,
        cvUrl,
        badges,
      ];
}

class SkillEntity extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;
  final String? svgContent;

  const SkillEntity({
    required this.id,
    required this.name,
    this.iconUrl,
    this.svgContent,
  });

  @override
  List<Object?> get props => [id, name, iconUrl, svgContent];
}

class ProjectEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final List<String> tags;
  final String? githubUrl;
  final String? playStoreUrl;
  final DateTime? createdAt;

  const ProjectEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.tags,
    this.githubUrl,
    this.playStoreUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, title, description, imageUrls, tags, githubUrl, playStoreUrl, createdAt];
}

class CertificateEntity extends Equatable {
  final String id;
  final String title;
  final String issuer;
  final String date;
  final String? credentialUrl;

  const CertificateEntity({
    required this.id,
    required this.title,
    required this.issuer,
    required this.date,
    this.credentialUrl,
  });

  @override
  List<Object?> get props => [id, title, issuer, date, credentialUrl];
}

class CustomerOpinionEntity extends Equatable {
  final String id;
  final String customerName;
  final String customerRole;
  final String company;
  final String comment;
  final int rating;

  const CustomerOpinionEntity({
    required this.id,
    required this.customerName,
    required this.customerRole,
    required this.company,
    required this.comment,
    required this.rating,
  });

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerRole,
        company,
        comment,
        rating,
      ];
}

class ExperienceEntity extends Equatable {
  final String id;
  final String company;
  final String role;
  final String startDate;
  final String endDate;
  final String description;

  const ExperienceEntity({
    required this.id,
    required this.company,
    required this.role,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  @override
  List<Object?> get props => [
        id,
        company,
        role,
        startDate,
        endDate,
        description,
      ];
}

class PortfolioDataEntity extends Equatable {
  final ProfileEntity profile;
  final List<SkillEntity> skills;
  final List<ProjectEntity> projects;
  final List<CertificateEntity> certificates;
  final List<CustomerOpinionEntity> opinions;
  final List<ExperienceEntity> experiences;

  const PortfolioDataEntity({
    required this.profile,
    required this.skills,
    required this.projects,
    required this.certificates,
    required this.opinions,
    required this.experiences,
  });

  @override
  List<Object?> get props => [
        profile,
        skills,
        projects,
        certificates,
        opinions,
        experiences,
      ];
}
