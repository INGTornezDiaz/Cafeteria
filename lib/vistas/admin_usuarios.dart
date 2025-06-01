import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({Key? key}) : super(key: key);

  @override
  _AdminUsuariosScreenState createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  String _selectedRole = 'Estudiante';
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _firebaseService.getUsers(_selectedRole);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando usuarios: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String id) async {
    try {
      await _firebaseService.deleteUser(_selectedRole, id);
      setState(() {
        _users.removeWhere((user) =>
            user['ID_No_Control'] == id ||
            user['ID_RFC'] == id ||
            user['ID_Chef'] == id);
      });
    } catch (e) {
      print('Error eliminando usuario: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              items: ['Estudiante', 'Docente', 'Chef']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                  _isLoading = true;
                });
                _loadUsers();
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de Usuario',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('No hay usuarios registrados'))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                  '${user['Nombre']} ${user['ApellidoP']} ${user['ApellidoM']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_selectedRole == 'Estudiante') ...[
                                    Text('Matrícula: ${user['ID_No_Control']}'),
                                    Text('Carrera: ${user['Carrera']}'),
                                    Text('Semestre: ${user['Semestre']}'),
                                  ],
                                  if (_selectedRole == 'Docente')
                                    Text('RFC: ${user['ID_RFC']}'),
                                  Text('Correo: ${user['Correo']}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          const Text('Confirmar eliminación'),
                                      content: const Text(
                                          '¿Estás seguro de eliminar este usuario?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await _deleteUser(user['ID_No_Control'] ??
                                          user['ID_RFC'] ??
                                          user['ID_Chef'].toString());
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Usuario eliminado'),
                                      ));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content:
                                            Text('Error al eliminar usuario'),
                                      ));
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
