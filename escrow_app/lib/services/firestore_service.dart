import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escrow_app/models/message_model.dart';
import 'package:escrow_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/contract_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   
  // Add to FirestoreService class
  Stream<List<Message>> getMessages(String contractId) {
    return _firestore
        .collection('chats')
        .doc(contractId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(String contractId, Message message) async {
    await _firestore
        .collection('chats')
        .doc(contractId)
        .collection('messages')
        .add({
      'text': message.text,
      'senderId': message.senderId,
      'timestamp': Timestamp.fromDate(message.timestamp),
    });
  }

  // Users
  Future<List<AppUser>> getUsers() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId,
            isNotEqualTo: currentUserId) // Exclude current user
        .get();

    // Map to ensure unique users by ID
    final users = snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();

    // Remove duplicates (if any)
    return users.toSet().toList();
  }

  // Contracts
  Future<void> createContract(Contract contract) async {
    final docRef = _firestore.collection('contracts').doc();
    await docRef.set({
      ...contract.toMap(),
      'id': docRef.id, // Store document ID in the data
    });
  }

  Stream<List<Contract>> getSentContracts(String userId) {
    return _firestore
        .collection('contracts')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contract.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Contract>> getReceivedContracts(String userId) {
    return _firestore
        .collection('contracts')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contract.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateContractStatus(String contractId, String status) async {
    await _firestore
        .collection('contracts')
        .doc(contractId)
        .update({'status': status});
  }
}
