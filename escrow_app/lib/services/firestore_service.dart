import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escrow_app/models/message_model.dart';
import 'package:escrow_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/contract_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  
  
  Stream<List<Message>> getMessages(String contractId) {
    return _firestore
        .collection('chats')
        .doc(contractId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) => print("Error fetching messages: $error"))
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
  Future<void> editMessage({
    required String contractId,
    required String messageId,
    required String newText,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(contractId)
          .collection('messages')
          .doc(messageId)
          .update({
        'text': newText,
        'edited': true, 
        'timestamp': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      print("Error editing message: $e");
      rethrow; 
    }
  }
  Future<void> deleteMessage({
    required String contractId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(contractId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Error deleting message: $e");
      rethrow;
    }
  }

  // Users
  Future<List<AppUser>> getUsers() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId,
            isNotEqualTo: currentUserId) 
        .get();

    
    final users = snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();

    
    return users.toSet().toList();
  }

  Future<AppUser?> getUserById(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return AppUser.fromMap(userDoc.data()!,userId);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  
  Future<void> createContract(Contract contract) async {
    final docRef = _firestore.collection('contracts').doc();
    await docRef.set({
      ...contract.toMap(),
      'id': docRef.id, 
    });
  }

  Future<Contract> getContract(String contractId) async {
    final doc = await _firestore.collection('contracts').doc(contractId).get();
    if (!doc.exists) throw Exception('Contract not found');
    return Contract.fromMap(doc.data()!, doc.id);
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
  Future<void> deleteContract(String contractId) async {
    try {
      await FirebaseFirestore.instance
          .collection('contracts')
          .doc(contractId)
          .delete();
    } catch (e) {
      print('Error deleting contract: $e');
      rethrow; 
    }
  }

  Future<void> updateContract(Contract contract) async {
    await FirebaseFirestore.instance
        .collection('contracts')
        .doc(contract.id)
        .update(contract.toMap());
  }

  Future<void> updateContractStatus(
    String contractId,
    String status,
    String receiverId,
  ) async {
    final docRef = _firestore.collection('contracts').doc(contractId);

    
    final contract =
        await docRef.get().then((s) => Contract.fromMap(s.data()!, s.id));
    if (contract.receiverId != receiverId) throw Exception('Unauthorized');

    await docRef.update({'status': status});

    
    if (status == 'accepted') {
      await _firestore.collection('chats').doc(contractId).set({
        'participants': [contract.senderId, contract.receiverId],
        'contractId': contractId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
