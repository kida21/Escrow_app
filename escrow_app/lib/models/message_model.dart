import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool edited;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    this.edited = false,
  });

  factory Message.fromMap(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      text: data['text'],
      senderId: data['senderId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      edited: data['edited'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
