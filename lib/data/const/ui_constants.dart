import 'package:flutter/material.dart';

class BorderRadiusConstants {
  static const double borderRadius = 8.0;
  static final BorderRadius defaultBorderRadius = BorderRadius.circular(borderRadius);

  static final InputBorder defaultInputBorder = OutlineInputBorder(
    borderRadius: defaultBorderRadius,
  );
}