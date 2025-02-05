import 'package:escrow_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/create_contract_screen.dart';
import 'screens/pending_contract_screen.dart';
import 'screens/signup_screen.dart';
import 'services/firestore_service.dart';
import 'services/auth_service.dart';
import 'screens/contract_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   
  await Firebase.initializeApp(
    options:const FirebaseOptions(
      apiKey: "AIzaSyCn-Y_lwKG_1oVpRAwQ0vWkEyFkWm4-f4o", 
      appId: "1:1090202880600:android:5e64b3882bf7a04a75182d", 
      messagingSenderId: "1090202880600", 
      projectId: "escrow-2bb21"
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'Escrow App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            final currentUserId = authService.currentUser;
            if (currentUserId == null) {
              return LoginScreen(); 
            } else {
              return const ContractScreen(); 
            }
          },
        ),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/contracts': (context) => const ContractScreen(),
          '/create-contract': (context) => const CreateContractScreen(),
          '/pending-contracts': (context) => const PendingContractsScreen(),
        },
      ),
    );
  }
}
