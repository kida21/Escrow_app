import 'package:escrow_app/models/message_model.dart';
import 'package:escrow_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class MessageInput extends StatelessWidget {
  final String contractId;
  final TextEditingController _controller = TextEditingController();

  MessageInput({super.key, required this.contractId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final currentUserId = Provider.of<AuthService>(context).currentUser;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (_controller.text.trim().isNotEmpty) {
                await firestoreService.sendMessage(
                  contractId,
                  Message(
                    id: '',
                    text: _controller.text.trim(),
                    senderId: currentUserId!.id,
                    timestamp: DateTime.now(),
                  ),
                );
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
