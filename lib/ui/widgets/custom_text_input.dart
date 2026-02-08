import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/const/ui_constants.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';

class CustomTextInput extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextInput({
    super.key,
    required this.label,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: BorderRadiusConstants.defaultInputBorder,
      ),
      style: TextStyle(
        color: AppTheme.onSurface,
      ),
    );
  }
  
}