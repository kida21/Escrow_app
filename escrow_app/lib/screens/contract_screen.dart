import 'package:escrow_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/contract_model.dart';
import 'chat_screen.dart';

class ContractScreen extends StatelessWidget {
const ContractScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final currentUserId = Provider.of<AuthService>(context).getCurrentUserId();

    return Scaffold(
      appBar: AppBar(title: const Text('Contracts')),
      body: FutureBuilder<List<Contract>>(
        future: firestoreService.getContracts(currentUserId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var contracts = snapshot.data!;
          return ListView.builder(
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              var contract = contracts[index];
              return ListTile(
                title: Text('Contract ID: ${contract.id}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(contractId: contract.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
