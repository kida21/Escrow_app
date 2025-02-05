import 'package:escrow_app/models/contract_model.dart';
import 'package:escrow_app/screens/contract_detail_screen.dart';
import 'package:escrow_app/screens/create_contract_screen.dart';
import 'package:escrow_app/screens/login_screen.dart';
import 'package:escrow_app/screens/pending_contract_screen.dart';
import 'package:escrow_app/services/auth_service.dart';
import 'package:escrow_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  void _handleDeleteContract(BuildContext context, Contract contract) async {
    
    bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content:
                const Text('Are you sure you want to delete this contract?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false; 

    if (shouldDelete) {
      try {
        final firestoreService =
            Provider.of<FirestoreService>(context, listen: false);
        await firestoreService
            .deleteContract(contract.id); // Ensure contract.id is non-null
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contract deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting contract: $e')),
          );
        }
      }
    }
  }

  void _handleEditContract(BuildContext context, Contract contract) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateContractScreen(contract: contract),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contracts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateContractScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) =>  LoginScreen()),
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
                  final isSender = contract.senderId == currentUser.id;

                  return Slidable(
                    key: ValueKey(contract.id),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        if (isSender) 
                          SlidableAction(
                            onPressed: (_) =>
                                _handleEditContract(context, contract),
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        if (isSender) 
                          SlidableAction(
                            onPressed: (_) =>
                                _handleDeleteContract(context, contract),
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(contract.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${contract.status}'),
                          Text(
                              'With: ${isSender ? contract.receiverId : contract.senderId}'),
                          Text(
                              '${DateFormat.yMd().format(contract.startDate)} - ${DateFormat.yMd().format(contract.endDate)}'),
                          Text(
                              '\$${contract.paymentAmount} - ${contract.paymentTerms}'),
                        ],
                      ),
                      trailing: contract.status == 'sent' && isSender
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
                    ),
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
