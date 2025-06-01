import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_button.dart';
import 'cart_page.dart';
import 'main_bebidas.dart';
import 'main_platillos.dart';
import 'main_postres.dart';
import 'mis_pedidos_page.dart';
import 'login.dart' as login_view;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/storage_service.dart';
import 'dart:io';

class MainMenu extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MainMenu({Key? key, required this.userData}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final CartController _cartController = Get.find<CartController>();
  final _storageService = StorageService();

  // Paleta de colores
  final Color primaryColor = Color(0xFFFF7F11); // Naranja vibrante
  final Color secondaryColor = Color(0xFFFFD700); // Amarillo dorado
  final Color backgroundColor = Color(0xFFF8F8F8); // Fondo claro
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      _buildProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navegar al carrito pasando los datos del usuario
      Get.to(() => CartPage(), arguments: widget.userData);
    } else {
      setState(() {
        _selectedIndex = index == 0 ? 0 : 1;
      });
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar platillos...',
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: primaryColor),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildMenuItemCard(Map<String, dynamic> item) {
    final precio = item['precioChef'] ?? item['precio'] ?? 0.0;
    final nombre = item['nombre']?.toString() ?? 'Sin nombre';
    final descripcion = item['descripcion']?.toString() ?? '';
    final imagen = item['imagen']?.toString();
    final id = item['id']?.toString() ?? '';
    final tipo = item['tipo']?.toString() ?? _getTipoFromCollection(item);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: imagen != null && imagen.isNotEmpty
                ? FutureBuilder<File?>(
                    future: _storageService.getImageFile(
                        imagen, _getImageType(tipo)),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.file(
                          snapshot.data!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      }
                      return Container(
                        height: 100,
                        color: Colors.grey[200],
                        child:
                            Icon(Icons.fastfood, size: 40, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item['precioChef'] != null) ...[
                            Text(
                              'Precio del Chef',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${precio.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Precio Sugerido',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${precio.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 4),
                    ElevatedButton.icon(
                      onPressed: () {
                        _cartController.addToCart(
                          id: id,
                          nombre: nombre,
                          precio: precio,
                          imagenUrl: imagen,
                          tipo: tipo,
                        );
                        Get.snackbar(
                          'Éxito',
                          'Agregado al carrito',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      icon: Icon(Icons.add_shopping_cart, size: 16),
                      label: Text('+'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
  }

  String _getTipoFromCollection(Map<String, dynamic> item) {
    // Si ya tiene tipo definido, usarlo
    if (item['tipo'] != null) return item['tipo'];

    // Determinar el tipo basado en la colección de origen
    final collectionPath = item['reference']?.path ?? '';
    if (collectionPath.contains('platillos')) return 'Platillo';
    if (collectionPath.contains('postres')) return 'Postre';
    if (collectionPath.contains('bebidas')) return 'Bebida';

    return 'Platillo'; // Valor por defecto
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
              color: textColor,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
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

            return Container(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: searchFilteredItems.length,
                itemBuilder: (context, index) {
                  final item =
                      searchFilteredItems[index].data() as Map<String, dynamic>;
                  item['id'] = searchFilteredItems[index].id;
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(right: 16),
                    child: _buildMenuItemCard(item),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildMenuSection(
            'Platillos',
            FirebaseFirestore.instance.collection('platillos').snapshots(),
          ),
          _buildMenuSection(
            'Postres',
            FirebaseFirestore.instance.collection('postres').snapshots(),
          ),
          _buildMenuSection(
            'Bebidas',
            FirebaseFirestore.instance.collection('bebidas').snapshots(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    final userRole = widget.userData['PK_ROL'];
    String roleDescription = '';
    bool isStudent = false;
    bool isTeacher = false;
    bool isAdmin = false;
    bool isChef = false;

    switch (userRole) {
      case 1:
        roleDescription = 'Administrador';
        isAdmin = true;
        break;
      case 2:
        roleDescription = 'Chef';
        isChef = true;
        break;
      case 3:
        roleDescription = 'Estudiante';
        isStudent = true;
        break;
      case 4:
        roleDescription = 'Docente';
        isTeacher = true;
        break;
      default:
        roleDescription = 'Usuario';
    }

    String fullName = '${widget.userData['Nombre'] ?? ''} '
            '${widget.userData['ApellidoP'] ?? ''} '
            '${widget.userData['ApellidoM'] ?? ''}'
        .trim();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            isStudent
                                ? Icons.school
                                : isTeacher
                                    ? Icons.work
                                    : isAdmin
                                        ? Icons.admin_panel_settings
                                        : Icons.restaurant_menu,
                            size: 40,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName.isNotEmpty
                                    ? fullName
                                    : 'Nombre no disponible',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  roleDescription,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (isStudent) ...[
                      if (widget.userData['ID_No_Control'] != null)
                        _buildInfoRow('Matrícula:',
                            widget.userData['ID_No_Control'].toString()),
                      if (widget.userData['Carrera'] != null)
                        _buildInfoRow(
                            'Carrera:', widget.userData['Carrera'].toString()),
                      if (widget.userData['Semestre'] != null)
                        _buildInfoRow('Semestre:',
                            widget.userData['Semestre'].toString()),
                    ] else if (isTeacher) ...[
                      if (widget.userData['ID_RFC'] != null)
                        _buildInfoRow(
                            'RFC:', widget.userData['ID_RFC'].toString()),
                    ] else if (isAdmin) ...[
                      if (widget.userData['ID_Admin'] != null)
                        _buildInfoRow('ID Admin:',
                            widget.userData['ID_Admin'].toString()),
                    ] else if (isChef) ...[
                      if (widget.userData['ID_Chef'] != null)
                        _buildInfoRow(
                            'ID Chef:', widget.userData['ID_Chef'].toString()),
                    ],
                    if (widget.userData['Correo'] != null)
                      _buildInfoRow(
                          'Correo:', widget.userData['Correo'].toString()),
                    if (widget.userData['Telefono'] != null)
                      _buildInfoRow(
                          'Teléfono:', widget.userData['Telefono'].toString()),
                    SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() =>
                                  MisPedidosPage(userData: widget.userData));
                            },
                            icon: Icon(Icons.receipt_long),
                            label: Text('Mis Pedidos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Get.offAllNamed('/');
                            },
                            icon: Icon(Icons.logout),
                            label: Text('Cerrar Sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: primaryColor,
              elevation: 0,
              title: Text(
                'Menú Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    // Aquí se implementará la funcionalidad de notificaciones
                    Get.snackbar(
                      'Notificaciones',
                      'No hay notificaciones pendientes',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.white,
                      colorText: primaryColor,
                    );
                  },
                ),
                CartButton(userData: widget.userData),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            )
          : null,
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: true,
            backgroundColor: cardColor,
            elevation: 10,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Carrito',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarritoItem {
  final String id;
  final String nombre;
  final double precio;
  final int cantidad;
  final String? imagenUrl;
  final String tipo;

  CarritoItem({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    this.imagenUrl,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'imagenUrl': imagenUrl,
      'tipo': tipo,
    };
  }

  factory CarritoItem.fromMap(Map<String, dynamic> map) {
    return CarritoItem(
      id: map['id'],
      nombre: map['nombre'],
      precio: map['precio'].toDouble(),
      cantidad: map['cantidad'],
      imagenUrl: map['imagenUrl'],
      tipo: map['tipo'],
    );
  }
}
