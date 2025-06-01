import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'main_menu.dart';
import 'views_chef.dart';
import 'views_administrador.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole = 'Estudiante';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  final FirebaseService _firebaseService = FirebaseService();

  // Paleta de colores
  final Color primaryColor = Color(0xFFFF7F11);
  final Color secondaryColor = Color(0xFFFFD700);
  final Color backgroundColor = Color(0xFFF8F8F8);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF333333);

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final user = await _firebaseService.loginUser(
          _userController.text.trim(),
          _passwordController.text,
          _selectedRole!,
        );

        setState(() => _isLoading = false);

        if (user != null) {
          switch (_selectedRole) {
            case 'Estudiante':
            case 'Docente':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainMenu(userData: user),
                ),
              );
              break;
            case 'Chef':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChefScreen(userData: user),
                ),
              );
              break;
            case 'Admin':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdministradorScreen(userData: user),
                ),
              );
              break;
          }
        } else {
          setState(() {
            _errorMessage = 'Credenciales incorrectas o usuario no existe';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error de conexión: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items: ['Admin', 'Chef', 'Estudiante', 'Docente']
                                .map((role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(
                                        role,
                                        style: TextStyle(color: textColor),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedRole = value),
                            decoration: InputDecoration(
                              labelText: 'Tipo de Usuario',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _userController,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su correo';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su contraseña';
                              }
                              return null;
                            },
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? CircularProgressIndicator()
                                  : Text('Iniciar Sesión'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
