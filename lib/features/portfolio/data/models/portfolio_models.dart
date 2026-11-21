import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/portfolio_entities.dart';

/// Single-line text (titles, names, dates...): trims and collapses any run of
/// whitespace, including stray line breaks, into one space.
String _line(dynamic value) =>
    (value ?? '').toString().replaceAll(RegExp(r'\s+'), ' ').trim();

/// Multi-line text (descriptions, bio...): a single line break in the middle
/// of a sentence becomes a space, while blank lines are kept as paragraph
/// breaks.
String _paragraphs(dynamic value) => (value ?? '')
    .toString()
    .split(RegExp(r'\n\s*\n'))
    .map(_line)
    .where((p) => p.isNotEmpty)
    .join('\n\n');

/// Optional link: blank values become null so no empty button is shown.
String? _optionalUrl(dynamic value) {
  final s = _line(value);
  return s.isEmpty ? null : s;
}

List<String> _lines(dynamic value) => value is List
    ? value.map(_line).where((s) => s.isNotEmpty).toList()
    : <String>[];

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
      name: _line(map['name']),
      title: _line(map['title']),
      subtitle: _paragraphs(map['subtitle']),
      bio: _paragraphs(map['bio']),
      photoUrl: map['photoUrl'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      github: map['github'] ?? '',
      linkedin: map['linkedin'] ?? '',
      cvUrl: map['cvUrl'] ?? '',
      badges: _lines(map['badges']),
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
      name: _line(map['name']),
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
    required super.imageUrls,
    required super.tags,
    super.githubUrl,
    super.playStoreUrl,
    super.appStoreUrl,
    super.createdAt,
    super.order,
  });

  factory ProjectModel.fromFirestore(Map<String, dynamic> map, String id) {
    // Handle migration from single imageUrl if needed
    List<String> urls = [];
    if (map['imageUrls'] != null) {
      urls = List<String>.from(map['imageUrls']);
    } else if (map['imageUrl'] != null && map['imageUrl'].toString().isNotEmpty) {
      urls = [map['imageUrl'].toString()];
    }

    return ProjectModel(
      id: id,
      title: _line(map['title']),
      description: _paragraphs(map['description']),
      imageUrls: urls,
      tags: _lines(map['tags']),
      githubUrl: _optionalUrl(map['githubUrl']),
      playStoreUrl: _optionalUrl(map['playStoreUrl']),
      appStoreUrl: _optionalUrl(map['appStoreUrl']),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      order: (map['order'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'imageUrls': imageUrls,
        'tags': tags,
        'githubUrl': githubUrl,
        'playStoreUrl': playStoreUrl,
        'appStoreUrl': appStoreUrl,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        // Only written when set, so updates never wipe an existing order.
        if (order != null) 'order': order,
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
      title: _line(map['title']),
      issuer: _line(map['issuer']),
      date: _line(map['date']),
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
      customerName: _line(map['customerName']),
      customerRole: _line(map['customerRole']),
      company: _line(map['company']),
      comment: _paragraphs(map['comment']),
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
      company: _line(map['company']),
      role: _line(map['role']),
      startDate: _line(map['startDate']),
      endDate: _line(map['endDate']),
      description: _paragraphs(map['description']),
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
