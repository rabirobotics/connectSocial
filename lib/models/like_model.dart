class Like {
  final String userId;
  final DateTime timestamp;

  Like({
    required this.userId,
    required this.timestamp,
  });

  factory Like.fromMap(Map<String, dynamic> data) {
    return Like(
      userId: data['userId'],
      timestamp: (data['timestamp']).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}
