import 'package:cloud_firestore/cloud_firestore.dart';

class Unlike {
  final String userId;
  final DateTime timestamp;

  Unlike({
    required this.userId,
    required this.timestamp,
  });

  factory Unlike.fromMap(Map<String, dynamic> data) {
    return Unlike(
      userId: data['userId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}
