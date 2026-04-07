import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String type; // 'proof', 'like', 'comment', 'follow', 'system'
  final DateTime time;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.time,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      time: json['time'] != null
          ? (json['time'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'time': Timestamp.fromDate(time),
      'isRead': isRead,
    };
  }
}
