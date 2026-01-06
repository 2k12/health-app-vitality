import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _isFocused ? AppTheme.primaryColor : Colors.grey[400],
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
              fontFamily: 'Roboto', // Explicitly Roboto
            ),
            child: Text(widget.label.toUpperCase()),
          ),
          const SizedBox(height: 8),

          // Input Container with Glow
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              // Glow effect only when focused
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              obscureText: widget.isPassword,
              keyboardType: widget.keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                fontFamily: 'Roboto',
              ),
              cursorColor: AppTheme.primaryColor,
              decoration: InputDecoration(
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppTheme.primaryColor
                            : Colors.grey[600],
                        size: 20,
                        shadows: _isFocused
                            ? [
                                const Shadow(
                                    color: AppTheme.primaryColor,
                                    blurRadius: 10)
                              ]
                            : [],
                      )
                    : null,
                // Hints
                hintText: 'Ingrese ${widget.label.toLowerCase()}',
                hintStyle: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
