import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lendledger/services/auth_service.dart';
import 'package:lendledger/utils/constants.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticating = false;
  String _biometricType = 'Biometric';

  @override
  void initState() {
    super.initState();
    _loadBiometricType();
    _authenticate();
  }

  Future<void> _loadBiometricType() async {
    final authService = context.read<AuthService>();
    final type = await authService.getBiometricTypeName();
    setState(() {
      _biometricType = type;
    });
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
    });

    final authService = context.read<AuthService>();
    final success = await authService.authenticate();

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.authenticationFailed),
          backgroundColor: AppColors.overdueRed,
        ),
      );
    }

    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 60,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingLarge),
                  
                  // App Name
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingSmall),
                  
                  // Tagline
                  Text(
                    'Professional Lending Tracker',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Biometric Icon
                  Icon(
                    _biometricType == 'Face ID' 
                        ? Icons.face 
                        : Icons.fingerprint,
                    size: 80,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingLarge),
                  
                  // Authentication Status
                  if (_isAuthenticating)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          AppStrings.authenticationRequired,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        ElevatedButton.icon(
                          onPressed: _authenticate,
                          icon: Icon(
                            _biometricType == 'Face ID' 
                                ? Icons.face 
                                : Icons.fingerprint,
                          ),
                          label: Text('Authenticate with $_biometricType'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingLarge,
                              vertical: AppSizes.paddingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // Security Notice
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppSizes.paddingSmall),
                        Text(
                          'Your data is encrypted and secure',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}