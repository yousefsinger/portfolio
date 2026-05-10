import '../../domain/entities/portfolio_entities.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.title,
    required super.subtitle,
    required super.bio,
    required super.photoUrl,
    required super.email,
    required super.phone,
    required super.github,
    required super.linkedin,
    required super.cvUrl,
    required super.badges,
  });

  factory ProfileModel.fromFirestore(Map<String, dynamic> map) {
    return ProfileModel(
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      github: map['github'] ?? '',
      linkedin: map['linkedin'] ?? '',
      cvUrl: map['cvUrl'] ?? '',
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'title': title,
        'subtitle': subtitle,
        'bio': bio,
        'photoUrl': photoUrl,
        'email': email,
        'phone': phone,
        'github': github,
        'linkedin': linkedin,
        'cvUrl': cvUrl,
        'badges': badges,
      };
}

class SkillModel extends SkillEntity {
  const SkillModel({
    required super.id,
    required super.name,
    super.iconUrl,
    super.svgContent,
  });

  factory SkillModel.fromFirestore(Map<String, dynamic> map, String id) {
    return SkillModel(
      id: id,
      name: map['name'] ?? '',
      iconUrl: map['iconUrl'],
      svgContent: map['svgContent'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'iconUrl': iconUrl,
        'svgContent': svgContent,
      };
}

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.tags,
    super.githubUrl,
    super.playStoreUrl,
  });

  factory ProjectModel.fromFirestore(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      githubUrl: map['githubUrl'],
      playStoreUrl: map['playStoreUrl'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'tags': tags,
        'githubUrl': githubUrl,
        'playStoreUrl': playStoreUrl,
      };
}

class CertificateModel extends CertificateEntity {
  const CertificateModel({
    required super.id,
    required super.title,
    required super.issuer,
    required super.date,
    super.credentialUrl,
  });

  factory CertificateModel.fromFirestore(Map<String, dynamic> map, String id) {
    return CertificateModel(
      id: id,
      title: map['title'] ?? '',
      issuer: map['issuer'] ?? '',
      date: map['date'] ?? '',
      credentialUrl: map['credentialUrl'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'issuer': issuer,
        'date': date,
        'credentialUrl': credentialUrl,
      };
}

class CustomerOpinionModel extends CustomerOpinionEntity {
  const CustomerOpinionModel({
    required super.id,
    required super.customerName,
    required super.customerRole,
    required super.company,
    required super.comment,
    required super.rating,
  });

  factory CustomerOpinionModel.fromFirestore(
    Map<String, dynamic> map,
    String id,
  ) {
    final rawRating = map['rating'];

    return CustomerOpinionModel(
      id: id,
      customerName: map['customerName'] ?? '',
      customerRole: map['customerRole'] ?? '',
      company: map['company'] ?? '',
      comment: map['comment'] ?? '',
      rating: rawRating is int
          ? rawRating.clamp(1, 5)
          : int.tryParse(rawRating?.toString() ?? '')?.clamp(1, 5) ?? 5,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'customerName': customerName,
        'customerRole': customerRole,
        'company': company,
        'comment': comment,
        'rating': rating.clamp(1, 5),
      };
}

class ExperienceModel extends ExperienceEntity {
  const ExperienceModel({
    required super.id,
    required super.company,
    required super.role,
    required super.startDate,
    required super.endDate,
    required super.description,
  });

  factory ExperienceModel.fromFirestore(Map<String, dynamic> map, String id) {
    return ExperienceModel(
      id: id,
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'company': company,
        'role': role,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };
}
