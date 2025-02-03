import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:escrow_app/services/auth_service.dart';
import 'package:escrow_app/services/firestore_service.dart';
import 'package:escrow_app/models/message_model.dart';
import 'package:escrow_app/widgets/message_bubble.dart';
import 'package:escrow_app/widgets/message_input.dart';

class ChatScreen extends StatelessWidget {
  final String contractId;

  const ChatScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final currentUser = Provider.of<AuthService>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Contract Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: firestoreService.getMessages(contractId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }

                final messages = snapshot.data ?? [];
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
  }
}
