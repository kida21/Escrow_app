import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:escrow_app/services/auth_service.dart';
import 'package:escrow_app/services/firestore_service.dart';
import 'package:escrow_app/models/message_model.dart';
import 'package:escrow_app/models/contract_model.dart';
import 'package:escrow_app/widgets/message_bubble.dart';
import 'package:escrow_app/widgets/message_input.dart';

class ChatScreen extends StatelessWidget {
  final String contractId;

  const ChatScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final currentUser = Provider.of<AuthService>(context).currentUser;

    return FutureBuilder<Contract>(
      future: firestoreService.getContract(contractId),
      builder: (context, contractSnapshot) {
        if (contractSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (contractSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Error loading contract: ${contractSnapshot.error}'),
            ),
          );
        }

        final contract = contractSnapshot.data!;

        // Check if contract is accepted
        if (contract.status != 'accepted') {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat Unavailable')),
            body: const Center(
              child: Text('Chat will be available once contract is accepted.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(contract.title)),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: firestoreService.getMessages(contractId),
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (messageSnapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error loading messages: ${messageSnapshot.error}'),
                      );
                    }

                    final messages = messageSnapshot.data ?? [];
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return MessageBubble(
                          message: message,
                          isMe: message.senderId == currentUser?.id,
                        );
                      },
                    );
                  },
                ),
              ),
              if (currentUser != null)
                MessageInput(contractId: contractId)
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('You must be logged in to send messages'),
                ),
            ],
          ),
        );
      },
    );
  }
}
