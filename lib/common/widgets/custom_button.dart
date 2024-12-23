import 'package:flutter/material.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final bool isLoading;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.color,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.isLoading = false,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? color ?? GlobalVariables.secondaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(30), // Bo tròn nhiều hơn
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor ??
                      (color != null ? Colors.black : Colors.white),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
