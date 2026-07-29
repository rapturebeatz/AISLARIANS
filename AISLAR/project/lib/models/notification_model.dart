import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String body;
  final NotificationData? data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'recipientId': recipientId,
    'type': type,
    'title': title,
    'body': body,
    'data': data?.toJson(),
    'isRead': isRead,
    'readAt': readAt,
    'createdAt': createdAt,
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) => NotificationModel(
    id: id,
    recipientId: json['recipientId'],
    type: json['type'],
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    data: json['data'] != null ? NotificationData.fromJson(json['data']) : null,
    isRead: json['isRead'] ?? false,
    readAt: json['readAt']?.toDate(),
    createdAt: json['createdAt'].toDate(),
  );

  factory NotificationModel.fromFcm(RemoteMessage message) {
    final data = message.data;
    return NotificationModel(
      id: message.messageId,
      recipientId: data['recipientId'] ?? '',
      type: data['type'] ?? 'system',
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: data.isNotEmpty ? NotificationData.fromJson(data) : null,
      createdAt: DateTime.now(),
    );
  }
}

class NotificationData {
  final String screen;
  final String? id;

  NotificationData({required this.screen, this.id});

  Map<String, dynamic> toJson() => {'screen': screen, 'id': id};

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    screen: json['screen'] ?? '',
    id: json['id'],
  );
}
