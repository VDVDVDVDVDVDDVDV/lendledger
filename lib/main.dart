import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lendledger/services/database_service.dart';
import 'package:lendledger/services/auth_service.dart';
import 'package:lendledger/screens/dashboard_screen.dart';
import 'package:lendledger/screens/auth_screen.dart';
import 'package:lendledger/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.instance.database;
  
  runApp(const LendLedgerApp());
}

class LendLedgerApp extends StatelessWidget {
  const LendLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Add more providers as needed
      ],
      child: MaterialApp(
        title: 'LendLedger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            brightness: Brightness.light,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}