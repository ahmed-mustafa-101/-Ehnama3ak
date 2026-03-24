import 'package:flutter/material.dart';

/// Custom TextFormField widget with consistent styling
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.showObscureToggle = false,
    this.onObscureToggle,
    this.borderRadius = 20.0,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
    this.hintStyle,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool showObscureToggle;
  final VoidCallback? onObscureToggle;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ?? const TextStyle(color: Colors.grey),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF42A5F5),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 2),
        ),
        contentPadding: contentPadding,
        suffixIcon: showObscureToggle && onObscureToggle != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onObscureToggle,
              )
            : null,
      ),
    );
  }
}

