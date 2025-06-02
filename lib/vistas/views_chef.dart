import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChefScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ChefScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _ChefScreenState createState() => _ChefScreenState();
}

class _ChefScreenState extends State<ChefScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  final _firestore = FirebaseFirestore.instance;
  final _imagePicker = ImagePicker();
  late TabController _tabController;

  File? _imageFile;
  bool _isLoading = false;
  String _tablaSeleccionada = 'Platillo';
  String _searchQuery = '';
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();

  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Seleccionar imagen'),
          content: Text('¿De dónde quieres obtener la imagen?'),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.photo_camera),
              label: Text('Cámara'),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            TextButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Galería'),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      );
      if (source == null) return;
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error al seleccionar la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la imagen: $e')),
      );
    }
  }

  Future<void> _guardarPlatillo(Map<String, dynamic> platilloData) async {
    try {
      setState(() => _isLoading = true);

      String? imageFileName;
      if (_imageFile != null) {
        switch (_tablaSeleccionada) {
          case 'Platillo':
            imageFileName =
                await _storageService.savePlatilloImage(_imageFile!);
            break;
          case 'Postre':
            imageFileName = await _storageService.savePostreImage(_imageFile!);
            break;
          case 'Bebidas':
            imageFileName = await _storageService.saveBebidaImage(_imageFile!);
            break;
        }
      }

      // Determinar la colección según el tipo
      String collection = '';
      String tipo = '';
      switch (_tablaSeleccionada) {
        case 'Platillo':
          collection = 'platillos';
          tipo = 'Platillo';
          break;
        case 'Postre':
          collection = 'postres';
          tipo = 'Postre';
          break;
        case 'Bebidas':
          collection = 'bebidas';
          tipo = 'Bebida'; // Cambiado de 'Bebidas' a 'Bebida'
          break;
      }

      // Preparar los datos según el tipo
      Map<String, dynamic> data = {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'precio': double.parse(_precioController.text),
        'precioChef': double.parse(_precioController.text),
        'cantidad': int.parse(_cantidadController.text),
        'chefId': widget.userData['uid'],
        'chefNombre': widget.userData['nombre'],
        'fechaCreacion': FieldValue.serverTimestamp(),
        'estado': 'activo',
        'imagen': imageFileName,
        'tipo': tipo,
        'categoria': _tipoController.text,
      };

      // Agregar campos específicos según el tipo
      if (_tablaSeleccionada == 'Bebidas') {
        data['cantidadMl'] = int.parse(_cantidadController.text);
      }

      // Guardar en la colección correspondiente
      await _firestore.collection(collection).add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_tablaSeleccionada} guardado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpiar el formulario
      _formKey.currentState?.reset();
      setState(() {
        _imageFile = null;
        _nombreController.clear();
        _descripcionController.clear();
        _precioController.clear();
        _cantidadController.clear();
        _tipoController.clear();
      });
    } catch (e) {
      print('Error al guardar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editarCampo(String campo, String valor) async {
    try {
      await _firestore
          .collection('chefs')
          .doc(widget.userData['uid'])
          .update({campo: valor});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Información actualizada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la información: $e')),
      );
    }
  }

  void _mostrarDialogoEdicion(String titulo, String campo, String valorActual) {
    final controller = TextEditingController(text: valorActual);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $titulo'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: titulo,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _editarCampo(campo, controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        leading: item['imagen'] != null
            ? FutureBuilder<File?>(
                future: _storageService.getImageFile(
                    item['imagen'], _getImageType(item['tipo'])),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return CircleAvatar(
                      radius: 25,
                      backgroundImage: FileImage(snapshot.data!),
                    );
                  }
                  return CircleAvatar(
                    child: Icon(Icons.fastfood),
                    backgroundColor: Colors.orange,
                  );
                },
              )
            : CircleAvatar(
                child: Icon(Icons.fastfood),
                backgroundColor: Colors.orange,
              ),
        title: Text(item['nombre'] ?? 'Sin nombre'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${item['precio']?.toString() ?? '0'}'),
            Text('Cantidad: ${item['cantidad']?.toString() ?? '0'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // TODO: Implementar edición
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                try {
                  String collection = _getCollectionName(item['tipo']);
                  await _firestore
                      .collection(collection)
                      .doc(item['id'])
                      .delete();

                  // Eliminar la imagen si existe
                  if (item['imagen'] != null) {
                    await _storageService.deleteImage(
                      item['imagen'],
                      _getImageType(item['tipo']),
                    );
                  }

                  // Forzar la actualización de la interfaz
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['tipo']} eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCollectionName(String? tipo) {
    switch (tipo) {
      case 'Platillo':
        return 'platillos';
      case 'Postre':
        return 'postres';
      case 'Bebidas':
        return 'bebidas';
      default:
        return 'platillos';
    }
  }

  String _getImageType(String? tipo) {
    switch (tipo) {
      case 'Platillo':
        return 'platillos';
      case 'Postre':
        return 'postres';
      case 'Bebida':
        return 'bebidas';
      default:
        return 'platillos';
    }
  }

  Widget _buildPedidosPendientes() {
    return Column(
      children: [
        // Filtros de estado
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilter('Todos', null),
                _buildStatusFilter('Pendientes', 'pending'),
                _buildStatusFilter('En Preparación', 'preparing'),
                _buildStatusFilter('Listos', 'ready'),
                _buildStatusFilter('Cancelados', 'cancelled'),
              ],
            ),
          ),
        ),
        // Lista de pedidos
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('ordenes')
                .where('status',
                    whereIn: _selectedStatus == null
                        ? ['pending', 'preparing', 'ready', 'cancelled']
                        : [_selectedStatus!])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Error al cargar pedidos: ${snapshot.error}');
                return Center(
                    child: Text('Error al cargar pedidos: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final pedidos = snapshot.data?.docs ?? [];

              if (pedidos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long,
                          size: 60, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        _selectedStatus == null
                            ? 'No hay pedidos'
                            : 'No hay pedidos ${_getStatusText(_selectedStatus!)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index].data() as Map<String, dynamic>;
                  final items = pedido['items'] as List<dynamic>? ?? [];
                  final status = pedido['status'] as String? ?? 'pending';
                  final timestamp = pedido['timestamp'] as Timestamp?;
                  final fecha = timestamp?.toDate() ?? DateTime.now();

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ExpansionTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                        ),
                      ),
                      title: Text(
                        'Pedido #${pedido['ID_Orden'] ?? pedidos[index].id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total: \$${pedido['Total']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(fecha)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Items del Pedido',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.orange,
                                ),
                              ),
                              SizedBox(height: 12),
                              ...items
                                  .map((item) => Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey[200]!),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item['nombre']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'x${item['cantidad']}',
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                              SizedBox(height: 16),
                              if (status != 'cancelled' && status != 'ready')
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _updateOrderStatus(
                                          pedidos[index].id,
                                          status == 'pending'
                                              ? 'preparing'
                                              : 'ready',
                                        ),
                                        icon: Icon(Icons.check_circle),
                                        label: Text(status == 'pending'
                                            ? 'Preparar'
                                            : 'Listo'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: status == 'pending'
                                              ? Colors.orange
                                              : Colors.green,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _updateOrderStatus(
                                          pedidos[index].id,
                                          'cancelled',
                                        ),
                                        icon: Icon(Icons.cancel),
                                        label: Text('Cancelar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt_long;
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('ordenes')
          .doc(orderId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado del pedido actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarPerfil() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('chefs')
            .doc(widget.userData['uid'])
            .snapshots(),
        builder: (context, snapshot) {
          print('UID del chef: ${widget.userData['uid']}');
          print('Documento existe: ${snapshot.data?.exists}');

          if (snapshot.hasError) {
            print('Error al cargar perfil: ${snapshot.error}');
            return _buildErrorProfile();
          }

          if (!snapshot.hasData) {
            return _buildLoadingProfile();
          }

          final chefData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          print('CHEF DATA COMPLETA: ' + chefData.toString());

          // Obtener los datos exactamente como están en Firestore
          final nombre = chefData['Nombre']?.toString().trim() ?? 'Sin nombre';
          final correo = chefData['Correo']?.toString().trim() ?? 'Sin correo';
          final usuario =
              chefData['Usuario']?.toString().trim() ?? 'Sin usuario';
          final rol = chefData['PK_ROL']?.toString() ?? '2';

          print('Nombre encontrado: $nombre');
          print('Correo encontrado: $correo');
          print('Usuario encontrado: $usuario');
          print('Rol encontrado: $rol');

          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.orange[100],
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        correo,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información Personal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoItem(
                          Icons.badge,
                          'Nombre',
                          nombre,
                        ),
                        _buildInfoItem(
                          Icons.email,
                          'Correo',
                          correo,
                        ),
                        _buildInfoItem(
                          Icons.person,
                          'Usuario',
                          usuario,
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/',
                                  (Route<dynamic> route) => false,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error al cerrar sesión: $e')),
                                );
                              }
                            },
                            icon: Icon(Icons.logout),
                            label: Text('Cerrar Sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
          );
        },
      ),
    );
  }

  Widget _buildLoadingProfile() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ),
    );
  }

  Widget _buildErrorProfile() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error al cargar el perfil',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel del Chef'),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.person),
              onPressed: _mostrarPerfil,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(icon: Icon(Icons.add_circle), text: 'Agregar'),
            Tab(icon: Icon(Icons.fastfood), text: 'Menú'),
            Tab(icon: Icon(Icons.notifications), text: 'Pedidos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de Agregar
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: _buildFormSection(),
                ),

          // Pestaña de Menú
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Platillos'),
                    Tab(text: 'Postres'),
                    Tab(text: 'Bebidas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Platillos
                      _buildMenuSection(
                        'Platillos',
                        _firestore.collection('platillos').snapshots()
                            as Stream<QuerySnapshot>,
                      ),
                      // Postres
                      _buildMenuSection(
                        'Postres',
                        _firestore.collection('postres').snapshots()
                            as Stream<QuerySnapshot>,
                      ),
                      // Bebidas
                      _buildMenuSection(
                        'Bebidas',
                        _firestore.collection('bebidas').snapshots()
                            as Stream<QuerySnapshot>,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pestaña de Pedidos
          _buildPedidosPendientes(),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar Nuevo ${_tablaSeleccionada}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonFormField<String>(
                value: _tablaSeleccionada,
                onChanged: (value) {
                  setState(() {
                    _tablaSeleccionada = value!;
                  });
                },
                items: ['Platillo', 'Postre', 'Bebidas']
                    .map((tabla) => DropdownMenuItem(
                          value: tabla,
                          child: Text(tabla),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Seleccionar tipo',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.table_chart, color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _imageFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit, color: Colors.orange),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 50, color: Colors.grey[400]),
                          SizedBox(height: 10),
                          Text(
                            'Toca para tomar una foto',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.fastfood, color: Colors.orange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.description, color: Colors.orange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _tipoController,
              decoration: InputDecoration(
                labelText: _tablaSeleccionada == 'Platillo'
                    ? 'Categoría del Platillo'
                    : _tablaSeleccionada == 'Postre'
                        ? 'Tipo de Postre'
                        : 'Tipo de Bebida',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.category, color: Colors.orange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioController,
                    decoration: InputDecoration(
                      labelText: 'Precio Sugerido',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon:
                          Icon(Icons.attach_money, color: Colors.orange),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Debe ser un número válido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _cantidadController,
                    decoration: InputDecoration(
                      labelText: _tablaSeleccionada == 'Bebidas'
                          ? 'Cantidad (ml)'
                          : 'Cantidad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.numbers, color: Colors.orange),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Debe ser un número válido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _guardarPlatillo({});
                        }
                      },
                icon: Icon(Icons.save),
                label: Text(
                  'Registrar ${_tablaSeleccionada}',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _imageFile!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add_photo_alternate,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildMenuSection(String title, Stream<QuerySnapshot> stream) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar los datos'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data?.docs ?? [];
              // Filtrar elementos sin nombre o con nombre vacío
              final filteredItems = items.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nombre = data['nombre']?.toString() ?? '';
                return nombre.isNotEmpty && nombre != 'Sin nombre';
              }).toList();

              // Aplicar filtro de búsqueda si existe
              final searchFilteredItems = _searchQuery.isEmpty
                  ? filteredItems
                  : filteredItems.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['nombre'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                    }).toList();

              if (searchFilteredItems.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No hay items disponibles'
                          : 'No se encontraron resultados',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: searchFilteredItems.length,
                itemBuilder: (context, index) {
                  var data =
                      searchFilteredItems[index].data() as Map<String, dynamic>;
                  data['id'] = searchFilteredItems[index].id;
                  return _buildMenuItemCard(data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.orange.withOpacity(0.2),
        checkmarkColor: Colors.orange,
        labelStyle: TextStyle(
          color: isSelected ? Colors.orange : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'pendientes';
      case 'preparing':
        return 'en preparación';
      case 'ready':
        return 'listos';
      case 'cancelled':
        return 'cancelados';
      default:
        return '';
    }
  }
}
