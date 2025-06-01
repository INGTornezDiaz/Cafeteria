import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_button.dart';

class MainBebidasPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> categoriasBebidas = [
    {
      'nombre': 'Agua',
      'imagen': 'windows/assets/agua.jpg',
      'subcategorias': [
        {'nombre': 'Agua natural', 'precio': '\$15'},
      ],
    },
    {
      'nombre': 'Café',
      'imagen': 'windows/assets/cafe.jpg',
      'subcategorias': [
        {'nombre': 'Café negro', 'precio': '\$25'},
        {'nombre': 'Café con leche', 'precio': '\$30'},
        {'nombre': 'Café americano', 'precio': '\$28'},
      ],
    },
    {
      'nombre': 'Té',
      'imagen': 'windows/assets/te.jpg',
      'subcategorias': [
        {'nombre': 'Té de manzanilla', 'precio': '\$20'},
        {'nombre': 'Té de limón', 'precio': '\$20'},
        {'nombre': 'Té verde', 'precio': '\$22'},
      ],
    },
    {
      'nombre': 'Aguas frescas',
      'imagen': 'windows/assets/agua_frescas.jpg',
      'subcategorias': [
        {'nombre': 'Piña', 'precio': '\$25'},
        {'nombre': 'Jamaica', 'precio': '\$25'},
        {'nombre': 'Melón', 'precio': '\$25'},
        {'nombre': 'Sandía', 'precio': '\$25'},
        {'nombre': 'Limón', 'precio': '\$25'},
        {'nombre': 'Horchata', 'precio': '\$28'},
      ],
    },
  ];

  // Paleta de colores profesional
  final Color primaryColor = Color(0xFFFF7F11); // Naranja vibrante
  final Color secondaryColor = Color(0xFFFFD700); // Amarillo dorado
  final Color backgroundColor = Color(0xFFF8F8F8); // Fondo claro
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF333333);

  MainBebidasPage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Bebidas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          CartButton(userData: userData),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorías',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: categoriasBebidas.length,
                itemBuilder: (context, index) {
                  final categoria = categoriasBebidas[index];
                  return GestureDetector(
                    onTap: () {
                      _mostrarSubcategorias(context, categoria);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Imagen de fondo
                            Positioned.fill(
                              child: Image.asset(
                                categoria['imagen'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: secondaryColor.withOpacity(0.2),
                                    child: Center(
                                      child: Icon(
                                        Icons.local_drink,
                                        size: 50,
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Overlay degradado
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Contenido
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      categoria['nombre'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${categoria['subcategorias'].length} opciones',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarSubcategorias(
      BuildContext context, Map<String, dynamic> categoria) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 5),
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          categoria['nombre'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48), // Para balancear el diseño
                  ],
                ),
              ),
              // Lista de subcategorías
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: categoria['subcategorias'].length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final subcategoria = categoria['subcategorias'][index];
                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_drink,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          subcategoria['nombre'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subcategoria['precio'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarDetalleBebida(context, subcategoria);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDetalleBebida(
      BuildContext context, Map<String, dynamic> bebida) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: secondaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.local_drink,
                    size: 50,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  bebida['nombre'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bebida['precio'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      try {
                        final cartController = Get.find<CartController>();
                        final precio = double.tryParse(bebida['precio']
                                .toString()
                                .replaceAll('\$', '')) ??
                            0.0;

                        print(
                            'Añadiendo al carrito: ${bebida['nombre']} - Precio: $precio');

                        final item = {
                          'nombre': bebida['nombre'],
                          'descripcion': bebida['descripcion'],
                          'precio': precio,
                          'imagen': bebida['imagen'],
                          'categoria': 'bebida',
                          'cantidad': 1
                        };

                        print('Item a añadir: $item');
                        cartController.addItem(item);

                        Navigator.pop(context);
                      } catch (e) {
                        print('Error al añadir al carrito: $e');
                        Get.snackbar(
                          'Error',
                          'No se pudo añadir al carrito: $e',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red[100],
                          colorText: Colors.red[800],
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Añadir al carrito',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
