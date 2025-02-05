import 'package:escrow_app/models/message_model.dart';
import 'package:escrow_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class MessageInput extends StatefulWidget {
  final String contractId;

  const MessageInput({super.key, required this.contractId});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

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
              focusNode: _focusNode, 
              readOnly: false,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) async {
                if (_controller.text.trim().isNotEmpty &&
                    currentUserId != null) {
                  await firestoreService.sendMessage(
                    widget.contractId,
                    Message(
                      id: '',
                      text: _controller.text.trim(),
                      senderId: currentUserId.id,
                      timestamp: DateTime.now(),
                    ),
                  );
                  _controller.clear();
                  _focusNode
                      .requestFocus(); 
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (_controller.text.trim().isNotEmpty && currentUserId != null) {
                await firestoreService.sendMessage(
                  widget.contractId,
                  Message(
                    id: '',
                    text: _controller.text.trim(),
                    senderId: currentUserId.id,
                    timestamp: DateTime.now(),
                  ),
                );
                _controller.clear();
                _focusNode
                    .requestFocus(); 
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); 
    super.dispose();
  }
}
