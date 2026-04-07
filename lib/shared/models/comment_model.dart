import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'User',
      userAvatarUrl: json['userAvatarUrl'] as String?,
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
