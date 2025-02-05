import 'package:escrow_app/models/contract_model.dart';
import 'package:escrow_app/models/user_model.dart';
import 'package:escrow_app/services/auth_service.dart';
import 'package:escrow_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateContractScreen extends StatefulWidget {
  final Contract? contract; 

  const CreateContractScreen({super.key, this.contract});

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

 @override
  void initState() {
    super.initState();

    
    if (widget.contract != null) {
      final contract = widget.contract!;
      _titleController.text = contract.title;
      _paymentAmountController.text = contract.paymentAmount.toString();
      _paymentTermsController.text = contract.paymentTerms;
      _startDate = contract.startDate;
      _endDate = contract.endDate;

      
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final firestoreService =
              Provider.of<FirestoreService>(context, listen: false);
          final receiver =
              await firestoreService.getUserById(contract.receiverId);

          if (receiver != null) {
            setState(() {
              _selectedReceiver = receiver; 
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error loading receiver details')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching receiver: $e')),
          );
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
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
        title: Text(
            widget.contract == null ? 'Create New Contract' : 'Edit Contract'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
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
                    items: users
                        .map((user) => DropdownMenuItem<AppUser>(
                              value: user,
                              child: Text(user.name),
                            ))
                        .toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a receiver';
                      }
                      return null;
                    },
                    onChanged: (user) =>
                        setState(() => _selectedReceiver = user),
                  );
                },
              ),
              const SizedBox(height: 30),
              
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

                      final contract = Contract(
                        id: widget.contract?.id ??
                            '', 
                        title: _titleController.text,
                        senderId: currentUser.id,
                        receiverId: _selectedReceiver!.id,
                        startDate: _startDate!,
                        endDate: _endDate!,
                        paymentAmount:
                            double.parse(_paymentAmountController.text),
                        paymentTerms: _paymentTermsController.text,
                        createdAt: widget.contract?.createdAt ?? DateTime.now(),
                      );

                      if (widget.contract == null) {
                        
                        await firestoreService.createContract(contract);
                      } else {
                        
                        await firestoreService.updateContract(contract);
                      }

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving contract: $e')),
                      );
                    }
                  }
                },
                child: Text(
                  widget.contract == null ? 'Create Contract' : 'Save Changes',
                  style: const TextStyle(fontSize: 16),
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

