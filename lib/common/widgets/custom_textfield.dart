import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator; // Thêm validator tùy chỉnh
  final TextInputType? keyboardType; 

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator, // Thêm vào constructor
     this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.orange,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          errorBorder: OutlineInputBorder( // Thêm style cho error border
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedErrorBorder: OutlineInputBorder( // Thêm style cho focused error border
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          errorStyle: const TextStyle( // Style cho error text
            fontSize: 12,
            color: Colors.red,
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator ?? (val) { // Sử dụng custom validator nếu có, không thì dùng default
          if (val == null || val.isEmpty) {
            return 'Please enter ${hintText.toLowerCase()}';
          }
          return null;
        },
        maxLines: obscureText ? 1 : maxLines,
        style: const TextStyle( // Style cho input text
          fontSize: 14,
          color: Colors.black87,
        ),
        cursorColor: Colors.orange, // Màu con trỏ
        textInputAction: TextInputAction.next, // Action next trên keyboard
        keyboardType: _getKeyboardType(), // Loại keyboard phù hợp
      ),
    );
  }

  // Helper method để xác định loại keyboard
  TextInputType _getKeyboardType() {
    if (hintText.toLowerCase().contains('email')) {
      return TextInputType.emailAddress;
    } else if (hintText.toLowerCase().contains('phone')) {
      return TextInputType.phone;
    } else if (hintText.toLowerCase().contains('password')) {
      return TextInputType.visiblePassword;
    }
    return TextInputType.text;
  }
}