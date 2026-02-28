import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/dairy_theme.dart';

/// Premium Text Input Field with enhanced styling
class PremiumInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? errorText;

  const PremiumInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
    this.focusNode,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: DairyTypography.label(isDark: isDark),
          ),
          const SizedBox(height: DairySpacing.sm),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          style: DairyTypography.bodyLarge(isDark: isDark),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}

/// Premium Phone Input with country code
class PremiumPhoneInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;

  const PremiumPhoneInput({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? DairyColors.dark() : DairyColors.light();

    return PremiumInput(
      label: 'Phone Number',
      hint: 'Enter your phone number',
      controller: controller,
      keyboardType: TextInputType.phone,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Text(
          '+91',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: validator,
      onChanged: onChanged,
      errorText: errorText,
    );
  }
}

/// Premium OTP Input with styling
class PremiumOTPInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;

  const PremiumOTPInput({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumInput(
      label: 'OTP',
      hint: 'Enter 6-digit OTP',
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      prefixIcon: const Icon(Icons.lock_outline),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: validator,
      onChanged: onChanged,
      errorText: errorText,
    );
  }
}

