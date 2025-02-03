import 'package:cloud_firestore/cloud_firestore.dart';

class Contract {
  final String id;
  final String title;
  final String senderId;
  final String receiverId;
  final DateTime startDate;
  final DateTime endDate;
  final double paymentAmount;
  final String paymentTerms;
  final String status; 
  final DateTime createdAt;

  Contract({
    required this.id,
    required this.title,
    required this.senderId,
    required this.receiverId,
    required this.startDate,
    required this.endDate,
    required this.paymentAmount,
    required this.paymentTerms,
    this.status = 'draft',
    required this.createdAt,
  });

  factory Contract.fromMap(Map<String, dynamic> data, String id) => Contract(
        id: id,
        title: data['title'],
        senderId: data['senderId'],
        receiverId: data['receiverId'],
        startDate: (data['startDate'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        paymentAmount: data['paymentAmount'].toDouble(),
        paymentTerms: data['paymentTerms'],
        status: data['status'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'senderId': senderId,
        'receiverId': receiverId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'paymentAmount': paymentAmount,
        'paymentTerms': paymentTerms,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
