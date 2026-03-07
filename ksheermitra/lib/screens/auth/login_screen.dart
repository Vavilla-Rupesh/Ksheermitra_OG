import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../providers/auth_provider.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/premium_widgets.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOTP(phone);

    if (!mounted) return;

    if (success) {
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Failed to send OTP')),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOTP(phone, otp);

    if (!mounted) return;

    if (success && authProvider.user != null) {
      final user = authProvider.user!;
      final themeProvider = Provider.of<DairyThemeProvider>(context, listen: false);

      if (user.isCustomer) {
        themeProvider.setRole(UserRole.customer);
        Navigator.of(context).pushReplacementNamed('/customer-home');
      } else if (user.isDeliveryBoy) {
        themeProvider.setRole(UserRole.deliveryBoy);
        Navigator.of(context).pushReplacementNamed('/delivery-home');
      } else if (user.isAdmin) {
        themeProvider.setRole(UserRole.admin);
        Navigator.of(context).pushReplacementNamed('/admin-home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Account not found. Please sign up first.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignupScreen(
          phone: _phoneController.text.trim(),
          otp: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.dashboardHeaderGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.space24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo with gradient background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.premiumCardShadow,
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.local_drink,
                              size: 60,
                              color: AppTheme.primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space24),
                  const Text(
                    'Welcome to Ksheermitra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space12),
                  const Text(
                    'Fresh Milk, Delivered Daily',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),
                  const Text(
                    'Enter your phone number to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space48),

                  // Login Card with Premium styling
                  PremiumCard(
                    padding: const EdgeInsets.all(AppTheme.space24),
                    shadows: AppTheme.premiumCardShadow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PremiumPhoneInput(
                          controller: _phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (value.length != 10) {
                              return 'Phone number must be 10 digits';
                            }
                            return null;
                          },
                        ),

                        if (_otpSent) ...[
                          const SizedBox(height: AppTheme.space24),
                          Text(
                            'Enter OTP',
                            style: DairyTypography.headingSmall(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.space16),
                          Pinput(
                            controller: _otpController,
                            length: 6,
                            onCompleted: (pin) => _verifyOTP(),
                            defaultPinTheme: PinTheme(
                              width: 50,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                border: Border.all(color: Colors.transparent),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 50,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                border: Border.all(color: AppTheme.primaryColor, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.space12),
                          PremiumTextButton(
                            text: 'Change Phone Number',
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                                _otpController.clear();
                              });
                            },
                          ),
                        ],

                        const SizedBox(height: AppTheme.space24),

                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return PremiumButton(
                              text: _otpSent ? 'Verify & Login' : 'Send OTP',
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _otpSent
                                      ? _verifyOTP
                                      : _sendOTP,
                              isLoading: authProvider.isLoading,
                              icon: _otpSent ? Icons.login : Icons.send,
                            );
                          },
                        ),

                        const SizedBox(height: AppTheme.space16),
                        Text(
                          'By continuing, you agree to our Terms of Service',
                          style: AppTheme.caption,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppTheme.space20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            PremiumTextButton(
                              text: 'Sign Up',
                              onPressed: _navigateToSignup,
                            ),
                          ],
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
