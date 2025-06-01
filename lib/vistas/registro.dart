import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Estudiante';
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final FirebaseService _firebaseService = FirebaseService();

  // Paleta de colores premium
  final Color primaryColor = Color(0xFFFF7F11);
  final Color secondaryColor = Color(0xFFFFD700);
  final Color backgroundColor = Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF444444);
  final Color borderColor = Color(0xFFEEEEEE);

  // Controladores
  final List<TextEditingController> _controllers =
      List.generate(11, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_controllers[8].text != _controllers[9].text) {
        _showErrorSnackbar('Las contraseñas no coinciden');
        return;
      }

      setState(() => _isLoading = true);

      final userData = {
        'Nombre': _controllers[0].text,
        'ApellidoPaterno': _controllers[1].text,
        'ApellidoMaterno': _controllers[2].text,
        'Correo': _controllers[7].text,
        'Telefono': _controllers[6].text,
        'Contrasena': _controllers[8].text,
        if (_selectedRole == 'Estudiante') ...{
          'matricula': _controllers[3].text,
          'Carrera': _controllers[4].text,
          'Semestre': int.parse(_controllers[5].text),
        },
        if (_selectedRole == 'Docente') ...{
          'RFC': _controllers[10].text,
        },
      };

      try {
        bool success = false;
        switch (_selectedRole) {
          case 'Estudiante':
            success = await _firebaseService.registerEstudiante(userData);
            break;
          case 'Docente':
            success = await _firebaseService.registerDocente(userData);
            break;
        }

        if (success) {
          _showSuccessSnackbar('Registro exitoso');
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context);
        } else {
          _showErrorSnackbar('Error en el registro');
        }
      } catch (e) {
        _showErrorSnackbar(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: cardColor,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownFormField({
    required TextEditingController controller,
    required String labelText,
    required List<String> items,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.text = newValue;
        }
      },
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: cardColor,
      ),
      validator: validator,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Registro de Usuario'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Tipo de Usuario'),
                        SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          items: ['Estudiante', 'Docente']
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Row(
                                      children: [
                                        Icon(
                                          role == 'Estudiante'
                                              ? Icons.school
                                              : Icons.work,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          role,
                                          style: TextStyle(color: textColor),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRole = value!),
                          decoration: InputDecoration(
                            labelText: 'Seleccione su rol',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: cardColor,
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildSectionTitle('Información Personal'),
                        SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _controllers[0],
                          labelText: 'Nombre',
                          icon: Icons.person_outline,
                          validator: (value) =>
                              value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _controllers[1],
                          labelText: 'Apellido Paterno',
                          icon: Icons.person_outline,
                          validator: (value) =>
                              value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _controllers[2],
                          labelText: 'Apellido Materno',
                          icon: Icons.person_outline,
                          validator: (value) =>
                              value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _controllers[6],
                          labelText: 'Teléfono',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _controllers[7],
                          labelText: 'Correo Electrónico',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo obligatorio';
                            }
                            if (!value.contains('@')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        _buildSectionTitle('Seguridad'),
                        SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _controllers[8],
                          labelText: 'Contraseña',
                          icon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo obligatorio';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _controllers[9],
                          labelText: 'Confirmar Contraseña',
                          icon: Icons.lock_outline,
                          obscureText: !_isConfirmPasswordVisible,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo obligatorio';
                            }
                            if (value != _controllers[8].text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        if (_selectedRole == 'Estudiante') ...[
                          _buildSectionTitle('Información Académica'),
                          SizedBox(height: 15),
                          _buildTextFormField(
                            controller: _controllers[3],
                            labelText: 'Matrícula',
                            icon: Icons.badge_outlined,
                            validator: (value) =>
                                value!.isEmpty ? 'Campo obligatorio' : null,
                          ),
                          SizedBox(height: 15),
                          _buildDropdownFormField(
                            controller: _controllers[4],
                            labelText: 'Carrera',
                            items: [
                              'Informática',
                              'Turismo',
                              'Gestión',
                              'Gastronomía',
                              'Agronomía'
                            ],
                            icon: Icons.school_outlined,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Seleccione una carrera'
                                : null,
                          ),
                          SizedBox(height: 15),
                          _buildTextFormField(
                            controller: _controllers[5],
                            labelText: 'Semestre',
                            icon: Icons.numbers_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'Campo obligatorio' : null,
                          ),
                          SizedBox(height: 20),
                        ],
                        if (_selectedRole == 'Docente') ...[
                          _buildSectionTitle('Información Laboral'),
                          SizedBox(height: 15),
                          _buildTextFormField(
                            controller: _controllers[10],
                            labelText: 'RFC',
                            icon: Icons.assignment_ind_outlined,
                            validator: (value) =>
                                value!.isEmpty ? 'Campo obligatorio' : null,
                          ),
                          SizedBox(height: 20),
                        ],
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registerUser,
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : Text('Registrarse'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
