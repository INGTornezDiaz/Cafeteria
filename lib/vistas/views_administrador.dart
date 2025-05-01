import 'package:flutter/material.dart';

class AdministradorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administrador')),
      body: Center(
        child: Text(
          'Bienvenido Administrador',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
