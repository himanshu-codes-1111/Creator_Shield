import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType { image, video, audio, document }

enum LicenseType { allRightsReserved, creativeCommons, commercial, custom }

class PostModel {
  final String id;
  final String creatorId;
  final String creatorName;
  final String creatorUsername;
  final String? creatorAvatarUrl;
  final bool creatorVerified;
  final String title;
  final String? description;
  final ContentType contentType;
  final String? previewUrl;
  final List<String> tags;
  final String category;
  final String fileHash;
  final String? txId;
  final bool isOnChain;
  final LicenseType licenseType;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isLiked;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.creatorUsername,
    this.creatorAvatarUrl,
    this.creatorVerified = false,
    required this.title,
    this.description,
    required this.contentType,
    this.previewUrl,
    this.tags = const [],
    required this.category,
    required this.fileHash,
    this.txId,
    this.isOnChain = false,
    this.licenseType = LicenseType.allRightsReserved,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      creatorUsername: json['creatorUsername'] as String,
      creatorAvatarUrl: json['creatorAvatarUrl'] as String?,
      creatorVerified: json['creatorVerified'] as bool? ?? false,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentType: ContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => ContentType.image,
      ),
      previewUrl: json['previewUrl'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] as String,
      fileHash: json['fileHash'] as String,
      txId: json['txId'] as String?,
      isOnChain: json['isOnChain'] as bool? ?? false,
      licenseType: LicenseType.values.firstWhere(
        (e) => e.name == json['licenseType'],
        orElse: () => LicenseType.allRightsReserved,
      ),
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : (json['createdAt'] as Timestamp).toDate()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorUsername': creatorUsername,
      'creatorAvatarUrl': creatorAvatarUrl,
      'creatorVerified': creatorVerified,
      'title': title,
      'description': description,
      'contentType': contentType.name,
      'previewUrl': previewUrl,
      'tags': tags,
      'category': category,
      'fileHash': fileHash,
      'txId': txId,
      'isOnChain': isOnChain,
      'licenseType': licenseType.name,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
