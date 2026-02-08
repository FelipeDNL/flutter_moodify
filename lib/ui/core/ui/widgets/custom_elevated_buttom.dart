import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/const/ui_constants.dart';

class CustomFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;

  const CustomFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusConstants.defaultBorderRadius,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color? textColor;
  final double? width;

  const CustomOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.borderColor,
    this.textColor = Colors.white,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          foregroundColor: textColor ?? borderColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusConstants.defaultBorderRadius,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

