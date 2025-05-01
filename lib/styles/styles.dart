import 'package:flutter/material.dart';

class Styles {
  // Estilo para el título
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Decoración común para los campos de texto
  static InputDecoration inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
    );
  }
}
