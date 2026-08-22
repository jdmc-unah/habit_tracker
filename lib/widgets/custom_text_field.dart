import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Widget? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final String? initialValue;
  final Color? fillColor;
  final Color? textColor;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onSaved,
    this.onChanged,
    this.initialValue,
    this.fillColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      onSaved: onSaved,
      onChanged: onChanged,
      style: TextStyle(
        color:
            textColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        fillColor:
            fillColor ?? Theme.of(context).inputDecorationTheme.fillColor,
        filled: true,
      ),
    );
  }
}
