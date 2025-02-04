import 'package:escrow_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contract_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class PendingContractsScreen extends StatelessWidget {
  const PendingContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final currentUser = Provider.of<AuthService>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Contracts')),
      body: StreamBuilder<List<Contract>>(
        stream: firestoreService.getReceivedContracts(currentUser!.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final contracts =
              snapshot.data!.where((c) => c.status == 'pending').toList();

          return ListView.builder(
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return ListTile(
                title: Text(contract.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: ${contract.senderId}'),
                    Text('Status: ${contract.status}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await firestoreService.updateContractStatus(
                          contract.id,
                          'accepted',
                          currentUser.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contract accepted!')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await firestoreService.updateContractStatus(
                          contract.id,
                          'rejected',
                          currentUser.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contract rejected!')),
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  if (contract.status == 'accepted') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(contractId: contract.id),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
