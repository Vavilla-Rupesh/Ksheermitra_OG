import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pinput/pinput.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class SignupScreen extends StatefulWidget {
  final String phone;
  final String otp;

  const SignupScreen({
    super.key,
    required this.phone,
    required this.otp,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  String _verifiedOtp = '';

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phone;

    // If OTP is provided (coming from login screen OTP verification)
    if (widget.otp.isNotEmpty) {
      _otpController.text = widget.otp;
      _verifiedOtp = widget.otp;
      _otpSent = true;
      _otpVerified = true;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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

    if (success) {
      setState(() {
        _otpVerified = true;
        _verifiedOtp = otp;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified! Please complete your registration.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Invalid OTP')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied. Please enable in settings.'),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = '';

          if (place.street != null && place.street!.isNotEmpty) {
            address += '${place.street}, ';
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            address += '${place.subLocality}, ';
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            address += '${place.locality}, ';
          }
          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            address += '${place.postalCode}';
          }

          _addressController.text = address;
        }
      } catch (e) {
        print('Error getting address: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location fetched successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify OTP first')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      otp: _verifiedOtp,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
    );

    if (!mounted) return;

    if (success && authProvider.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to customer home
      Navigator.of(context).pushReplacementNamed('/customer-home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: DairyTypography.headingLarge(),
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  'Please provide your details to get started',
                  textAlign: TextAlign.center,
                  style: DairyTypography.body(),
                ),
                const SizedBox(height: AppTheme.space32),

                // Phone number field
                TextFormField(
                  controller: _phoneController,
                  enabled: !_otpSent,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DairyRadius.md),
                    ),
                    filled: _otpSent,
                    fillColor: _otpSent ? DairyColorsLight.surface : null,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.trim().length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.space16),

                // OTP Section
                if (!_otpVerified) ...[
                  if (!_otpSent) ...[
                    ElevatedButton.icon(
                      onPressed: authProvider.isLoading ? null : _sendOTP,
                      icon: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Send OTP'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space12),
                    Pinput(
                      controller: _otpController,
                      length: 6,
                      onCompleted: (pin) => _verifyOTP(),
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 56,
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: DairyColorsLight.textPrimary,
                        ),
                        decoration: BoxDecoration(
                          color: DairyColorsLight.surface,
                          borderRadius: BorderRadius.circular(DairyRadius.sm),
                          border: Border.all(color: DairyColorsLight.border),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 50,
                        height: 56,
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: DairyColorsLight.textPrimary,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DairyRadius.sm),
                          border: Border.all(color: AppTheme.primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space12),
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Verify OTP'),
                    ),
                  ],
                  const SizedBox(height: AppTheme.space24),
                  const Divider(),
                  const SizedBox(height: AppTheme.space24),
                ],

                // Show registration form only after OTP is verified
                if (_otpVerified) ...[
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    decoration: BoxDecoration(
                      color: DairyColorsLight.successSurface,
                      borderRadius: BorderRadius.circular(DairyRadius.md),
                      border: Border.all(color: DairyColorsLight.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: DairyColorsLight.success, size: 20),
                        const SizedBox(width: DairySpacing.sm),
                        Expanded(
                          child: Text(
                            'OTP verified! Please complete your profile',
                            style: DairyTypography.bodySmall(color: DairyColorsLight.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.space24),

                  // Name field (required)
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DairyRadius.md),
                      ),
                      hintText: 'Enter your full name',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.space16),

                  // Email field (optional)
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email (Optional)',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DairyRadius.md),
                      ),
                      hintText: 'Enter your email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.space16),

                  // Address field (optional)
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address (Optional)',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DairyRadius.md),
                      ),
                      hintText: 'Enter your address',
                      suffixIcon: IconButton(
                        icon: _isLoadingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        tooltip: 'Use current location',
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppTheme.space8),

                  // Location help text
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: DairyColorsLight.textTertiary),
                      const SizedBox(width: DairySpacing.xs),
                      Expanded(
                        child: Text(
                          'Tap the location icon to auto-fill your current address',
                          style: DairyTypography.caption(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space32),

                  // Submit button
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DairyRadius.md),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Complete Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTheme.space16),

                  // Note
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.md),
                    decoration: BoxDecoration(
                      color: DairyColorsLight.infoSurface,
                      borderRadius: BorderRadius.circular(DairyRadius.md),
                      border: Border.all(color: DairyColorsLight.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock, size: 20, color: DairyColorsLight.info),
                        const SizedBox(width: DairySpacing.sm),
                        Expanded(
                          child: Text(
                            'Your information is secure and will only be used for delivery purposes.',
                            style: DairyTypography.bodySmall(color: DairyColorsLight.info),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

