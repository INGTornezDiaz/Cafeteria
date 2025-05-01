import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DB/conexion_login.dart';
import 'styles/styles.dart';

import 'vistas/views_cliente.dart'; // Vista para Cliente
import 'vistas/views_chef.dart'; // Vista para Chef
import 'vistas/views_administrador.dart'; // Vista para Administrador
import 'vistas/registro.dart'; // Vista de Registro
import 'vistas/main_menu.dart'; // Vista del menú principal

void main() {
  // Inicializar la base de datos
  DBHelper.printDatabasePath();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Comedor Universitario',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole = 'Estudiante';
  bool _isLoading = false;
  String? _errorMessage;

  bool _isEmailValid(String value) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(value) &&
        value.length <= 50;
  }

  bool _isPasswordValid(String value) {
    return value.length >= 4;
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        print(
            "Intentando login como: ${_selectedRole}, correo: ${_emailController.text}");

        // Validar que el rol sea uno de los permitidos
        if (!['Administrador', 'Chef', 'Estudiante', 'Docente']
            .contains(_selectedRole)) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Rol no válido';
          });
          return;
        }

        final userCredentials = await DBHelper.loginUser(
          _emailController.text,
          _passwordController.text,
          _selectedRole!,
        );

        setState(() {
          _isLoading = false;
        });

        if (userCredentials != null) {
          print("Login exitoso: ${userCredentials.toString()}");

          // Navegar según el rol
          switch (_selectedRole) {
            case 'Estudiante':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen()),
              );
              break;
            case 'Chef':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChefScreen()),
              );
              break;
            case 'Administrador':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdministradorScreen()),
              );
              break;
            case 'Docente':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen()),
              );
              break;
          }
        } else {
          print("Login fallido");
          setState(() {
            _errorMessage = 'Credenciales incorrectas o usuario no existe';
          });
        }
      } catch (e) {
        print("Error en login: ${e.toString()}");
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error de conexión: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sistema Comedor Universitario',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
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
                          if (!_isEmailValid(value)) {
                            return 'Ingrese un correo válido';
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contraseña';
                          }
                          if (!_isPasswordValid(value)) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Tipo de usuario',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Estudiante', 'Chef', 'Administrador', 'Docente']
                                .map((role) => DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role),
                                    ))
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      _isLoading
                          ? CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                child: Text('Iniciar Sesión'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
