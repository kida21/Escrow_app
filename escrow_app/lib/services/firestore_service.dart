import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/contract_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new contract and associated chat
  Future<void> createContract(Contract contract) async {
    await _firestore
        .collection('contracts')
        .doc(contract.id)
        .set(contract.toMap());
    await _firestore.collection('chats').doc(contract.id).set({
      'participants': [contract.clientId, contract.freelancerId],
      'contractId': contract.id,
    });
  }

  // Send a message
  Future<void> sendMessage(String contractId, Message message) async {
    await _firestore
        .collection('chats')
        .doc(contractId)
        .collection('messages')
        .add(message.toMap());
  }

  // Stream messages for a contract
  Stream<List<Message>> getMessages(String contractId) {
    return _firestore
        .collection('chats')
        .doc(contractId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

   // Add this method to FirestoreService
  Future<List<Contract>> getContracts(String userId) async {
    try {
      // Fetch contracts where the user is the client
      final clientContracts = await _firestore
          .collection('contracts')
          .where('clientId', isEqualTo: userId)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => Contract.fromMap(doc.data(), doc.id))
              .toList());

      // Fetch contracts where the user is the freelancer
      final freelancerContracts = await _firestore
          .collection('contracts')
          .where('freelancerId', isEqualTo: userId)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => Contract.fromMap(doc.data(), doc.id))
              .toList());

      // Combine both lists
      return [...clientContracts, ...freelancerContracts];
    } catch (e) {
      throw Exception('Failed to fetch contracts: $e');
    }
  }
}
