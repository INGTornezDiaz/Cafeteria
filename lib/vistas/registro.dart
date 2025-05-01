import 'package:flutter/material.dart';
import '../DB/conexion_login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole = 'Estudiante'; // Roles: Chef, Estudiante, Docente

  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController =
      TextEditingController();
  final TextEditingController _apellidoMaternoController =
      TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _carreraController = TextEditingController();
  final TextEditingController _semestreController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Imprimir la ruta de la base de datos al iniciar el registro
    DBHelper.printDatabasePath();
  }

  // Función para guardar un usuario
  Future<bool> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> userData = {
        'Nombre': _nombreController.text,
        'ApellidoPaterno': _apellidoPaternoController.text,
        'ApellidoMaterno': _apellidoMaternoController.text,
        'Correo': _emailController.text,
        'Contrasena': _passwordController.text,
      };

      // Agregar campos específicos según el rol
      switch (_selectedRole) {
        case 'Chef':
          return await DBHelper.registerChef(userData);
        case 'Estudiante':
          userData['Matricula'] = _matriculaController.text;
          userData['Carrera'] = _carreraController.text;
          userData['Semestre'] = _semestreController.text;
          return await DBHelper.registerEstudiante(userData);
        case 'Docente':
          userData['RFC'] = _rfcController.text;
          return await DBHelper.registerDocente(userData);
        default:
          return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: SingleChildScrollView(
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
                  children: [
                    Text('Crear cuenta',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),

                    // Menú desplegable para seleccionar el rol
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(labelText: 'Seleccionar rol'),
                      items: ['Chef', 'Estudiante', 'Docente']
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
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor seleccione un rol';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    // Campos comunes para todos los roles
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su nombre';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _apellidoPaternoController,
                      decoration:
                          InputDecoration(labelText: 'Apellido Paterno'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su apellido paterno';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _apellidoMaternoController,
                      decoration:
                          InputDecoration(labelText: 'Apellido Materno'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su apellido materno';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    // Campos específicos según el rol
                    if (_selectedRole == 'Estudiante') ...[
                      TextFormField(
                        controller: _matriculaController,
                        decoration: InputDecoration(labelText: 'Matrícula'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su matrícula';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _carreraController,
                        decoration: InputDecoration(labelText: 'Carrera'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su carrera';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _semestreController,
                        decoration: InputDecoration(labelText: 'Semestre'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su semestre';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                    ],

                    if (_selectedRole == 'Docente') ...[
                      TextFormField(
                        controller: _rfcController,
                        decoration: InputDecoration(labelText: 'RFC'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su RFC';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                    ],

                    // Campos comunes para todos los roles
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          InputDecoration(labelText: 'Correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un correo electrónico';
                        }
                        if (!RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value)) {
                          return 'Ingrese un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una contraseña';
                        }
                        if (value.length < 4) {
                          return 'La contraseña debe tener al menos 4 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        bool success = await _saveUser();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Usuario registrado exitosamente')));
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Error al registrar usuario. El correo ya existe o hubo un error.')));
                        }
                      },
                      child: Text('Registrar'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
