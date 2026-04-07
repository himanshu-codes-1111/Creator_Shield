enum CreatorTier { emerging, established, verified }

class UserModel {
  final String id;
  final String displayName;
  final String username;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final List<String> skills;
  final bool isVerified;
  final CreatorTier tier;
  final int worksCount;
  final int followersCount;
  final int followingCount;
  final int totalViews;
  final DateTime joinedAt;
  final String? walletAddress;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.username,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.skills = const [],
    this.isVerified = false,
    this.tier = CreatorTier.emerging,
    this.worksCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.totalViews = 0,
    required this.joinedAt,
    this.walletAddress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? 'Unknown',
      username: json['username'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      isVerified: json['isVerified'] as bool? ?? false,
      tier: CreatorTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => CreatorTier.emerging,
      ),
      worksCount: json['worksCount'] as int? ?? 0,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      walletAddress: json['walletAddress'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'username': username,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'skills': skills,
      'isVerified': isVerified,
      'tier': tier.name,
      'worksCount': worksCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'totalViews': totalViews,
      'joinedAt': joinedAt.toIso8601String(),
      'walletAddress': walletAddress,
    };
  }
}
