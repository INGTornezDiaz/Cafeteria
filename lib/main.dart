import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'controllers/cart_controller.dart';
import 'vistas/login.dart';
import 'vistas/main_menu.dart';
import 'vistas/views_chef.dart';
import 'vistas/views_administrador.dart';
import 'vistas/registro.dart';
import 'vistas/cart_page.dart';
import 'vistas/main_bebidas.dart';
import 'vistas/main_platillos.dart';
import 'vistas/main_postres.dart';
import 'vistas/mis_pedidos_page.dart';
import 'services/firebase_service.dart';
import 'services/init_database.dart';

Future<void> createAdminUser() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    // Verificar si el admin ya existe en Authentication
    try {
      await _auth.signInWithEmailAndPassword(
          email: 'apolinar12@gmail.com', password: 'admin123');
      print('El usuario administrador ya existe en Authentication');
    } catch (e) {
      // Si no existe, crearlo
      await _auth.createUserWithEmailAndPassword(
          email: 'apolinar12@gmail.com', password: 'admin123');
      print('Usuario administrador creado en Authentication');
    }

    // Verificar si el documento existe en Firestore
    final adminQuery = await _firestore
        .collection('admins')
        .where('Correo', isEqualTo: 'apolinar12@gmail.com')
        .get();

    if (adminQuery.docs.isEmpty) {
      // Crear el documento del admin
      await _firestore.collection('admins').add({
        'ID_Admin': 1,
        'PK_ROL': 1,
        'Usuario': 'apolinar12@gmail.com',
        'Contrasena': 'admin123',
        'Correo': 'apolinar12@gmail.com'
      });
      print('Documento de administrador creado en Firestore');
    } else {
      print('El documento de administrador ya existe en Firestore');
    }
  } catch (e) {
    print('Error al crear usuario administrador: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('es_MX', null);
  await createAdminUser(); // Crear el usuario admin al iniciar

  // Inicializar el controlador del carrito como permanente
  Get.put(CartController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Comedor App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo y título
                    Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            size: 60,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Sistema Comedor',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Inicia sesión para continuar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),

                    // Formulario de login
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
                                items: [
                                  'Admin',
                                  'Chef',
                                  'Estudiante',
                                  'Docente'
                                ]
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
                                  labelStyle: TextStyle(color: textColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: primaryColor),
                                  ),
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: primaryColor),
                                  filled: true,
                                  fillColor: cardColor,
                                ),
                                dropdownColor: cardColor,
                                style: TextStyle(color: textColor),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _userController,
                                decoration: InputDecoration(
                                  labelText: _selectedRole == 'Admin'
                                      ? 'Usuario'
                                      : 'Correo',
                                  labelStyle: TextStyle(color: textColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: primaryColor),
                                  ),
                                  prefixIcon: Icon(
                                    _selectedRole == 'Admin'
                                        ? Icons.person
                                        : Icons.email,
                                    color: primaryColor,
                                  ),
                                  filled: true,
                                  fillColor: cardColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return _selectedRole == 'Admin'
                                        ? 'Ingrese su usuario'
                                        : 'Ingrese su correo';
                                  }
                                  if (_selectedRole != 'Admin' &&
                                      !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                    return 'Ingrese un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  labelStyle: TextStyle(color: textColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: primaryColor),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.lock, color: primaryColor),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: cardColor,
                                ),
                                obscureText: !_isPasswordVisible,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Ingrese su contraseña'
                                        : value.length < 4
                                            ? 'Mínimo 4 caracteres'
                                            : null,
                              ),
                              SizedBox(height: 10),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              SizedBox(height: 20),
                              _isLoading
                                  ? CircularProgressIndicator(
                                      color: primaryColor)
                                  : ElevatedButton(
                                      onPressed: _login,
                                      child: Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        minimumSize: Size(double.infinity, 50),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        elevation: 5,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: '¿No tienes cuenta? ',
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: 'Regístrate aquí',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
