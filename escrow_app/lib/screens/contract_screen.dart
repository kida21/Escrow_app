import 'package:escrow_app/screens/contract_detail_screen.dart';
import 'package:escrow_app/screens/pending_contract_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/contract_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'create_contract_screen.dart';
import 'login_screen.dart';

class ContractScreen extends StatelessWidget {
  const ContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contracts'),
        actions: [
          // Add Contract Button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateContractScreen()),
            ),
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Contract>>(
        stream: firestoreService.getSentContracts(currentUser!.id),
        builder: (context, sentSnapshot) {
          return StreamBuilder<List<Contract>>(
            stream: firestoreService.getReceivedContracts(currentUser.id),
            builder: (context, receivedSnapshot) {
              if (sentSnapshot.connectionState == ConnectionState.waiting ||
                  receivedSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final sentContracts = sentSnapshot.data ?? [];
              final receivedContracts = receivedSnapshot.data ?? [];
              final allContracts = [...sentContracts, ...receivedContracts];

              if (allContracts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No contracts found'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateContractScreen(),
                          ),
                        ),
                        child: const Text('Create New Contract'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: allContracts.length,
                itemBuilder: (context, index) {
                  final contract = allContracts[index];
                  return ListTile(
                    title: Text(contract.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${contract.status}'),
                        Text(
                            'With: ${contract.senderId == currentUser.id ? contract.receiverId : contract.senderId}'),
                        Text(
                            '${DateFormat.yMd().format(contract.startDate)} - ${DateFormat.yMd().format(contract.endDate)}'),
                        Text(
                            '\$${contract.paymentAmount} - ${contract.paymentTerms}'),
                      ],
                    ),
                    trailing: contract.status == 'sent' &&
                            contract.senderId == currentUser.id
                        ? const Icon(Icons.pending_actions)
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ContractDetailScreen(contract: contract),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PendingContractsScreen()),
        ),
        
        tooltip: 'View Pending Contracts',
        child: const Icon(Icons.assignment),
      ),
    );
  }
}
