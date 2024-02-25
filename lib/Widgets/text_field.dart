import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Icon? prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final IconButton? suffixIcon;
  final bool isAutoValidateMode;
  const AppTextField(
      {super.key,
      required this.controller,
      this.hintText,
      this.prefixIcon,
      this.validator,
      this.obscureText = false,
      this.suffixIcon,
      this.isAutoValidateMode = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode:
          isAutoValidateMode ? AutovalidateMode.onUserInteraction : null,
      obscureText: obscureText,
      validator: validator,
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
