import 'package:escrow_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/contract_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CreateContractScreen extends StatefulWidget {
  const CreateContractScreen({super.key});

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  AppUser? _selectedReceiver;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Contract'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Contract Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Contract Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contract title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Start Date Picker
              ListTile(
                title: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start Date: ${DateFormat.yMMMMd().format(_startDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 10),

              // End Date Picker
              ListTile(
                title: Text(
                  _endDate == null
                      ? 'Select End Date'
                      : 'End Date: ${DateFormat.yMMMMd().format(_endDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 20),

              // Payment Details
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _paymentAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter payment amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _paymentTermsController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Terms',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter payment terms';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Receiver Selection Dropdown
              FutureBuilder<List<AppUser>>(
                future: firestoreService.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error loading users: ${snapshot.error}');
                  }
                  final users = snapshot.data ?? [];
                  return DropdownButtonFormField<AppUser>(
                    decoration: const InputDecoration(
                      labelText: 'Select Receiver',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_search),
                    ),
                    value: _selectedReceiver,
                    items: users.map((user)=> 
                       DropdownMenuItem<AppUser>(
                        value: user,
                        child: Text(user.name),
                      )
                    ).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a receiver';
                      }
                      return null;
                    },
                    onChanged: (user) =>
                        setState(() =>
                          _selectedReceiver = user
                          //print('Selected Receiver: ${user?.name}');
                        ),
                        
                  );
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _startDate != null &&
                      _endDate != null &&
                      _selectedReceiver != null) {
                    try {
                      final currentUser = authService.user;
                      if (currentUser == null)
                        throw Exception('User not logged in');

                      final newContract = Contract(
                        id: '', 
                        title: _titleController.text,
                        senderId: currentUser.id,
                        receiverId: _selectedReceiver!.id,
                        startDate: _startDate!,
                        endDate: _endDate!,
                        paymentAmount:
                            double.parse(_paymentAmountController.text),
                        paymentTerms: _paymentTermsController.text,
                        createdAt: DateTime.now(),
                      );

                      await firestoreService.createContract(newContract);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating contract: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Create Contract',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _paymentAmountController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }
}
