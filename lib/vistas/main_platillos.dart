import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_button.dart';
import 'cart_page.dart';

void main() {
  runApp(PlatillosApp());
}

class PlatillosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Platillos',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Color(0xFFF8F8F8), // Fondo claro
        primaryColor: Color(0xFFFF7F11), // Naranja vibrante
        colorScheme: ColorScheme.light(
          secondary: Color(0xFFFFD700), // Amarillo dorado
        ),
      ),
      home: MainPlatillosPage(userData: {}),
    );
  }
}

class MainPlatillosPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Color primaryColor = Color(0xFFFF7F11);
  final Color secondaryColor = Color(0xFFFFD700);
  final Color backgroundColor = Color(0xFFF8F8F8);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF333333);

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Sopas',
      'image':
          'https://jetextramar.com/wp-content/uploads/2021/09/receta-fideo-grueso-empresa-de-alimentos-700x525.jpg',
      'items': [
        {
          'nombre': 'Sopa de Verduras',
          'descripcion': 'Con zanahoria, papa, calabaza y elote.',
          'imagen':
              'https://mejorconsalud.as.com/wp-content/uploads/2018/07/sopa-verduras-1.jpg',
          'precio': '\$65'
        },
        {
          'nombre': 'Crema de Elote',
          'descripcion': 'Suave y cremosa, ideal para el almuerzo.',
          'imagen': 'https://i.blogs.es/59dd70/crema-de-elote/1366_2000.jpg',
          'precio': '\$70'
        },
      ],
    },
    {
      'title': 'Ensaladas',
      'image':
          'https://exoticfruitbox.com/wp-content/uploads/2017/01/ensalada-detox-con-frutas-tropicales-dos-800x533.jpg',
      'items': [
        {
          'nombre': 'Ensalada César',
          'descripcion': 'Lechuga fresca con aderezo y crutones.',
          'imagen':
              'https://sarasellos.com/wp-content/uploads/2024/07/ensalada-cesar1-1024x684.jpg',
          'precio': '\$75'
        },
        {
          'nombre': 'Ensalada de Frutas',
          'descripcion': 'Fresca mezcla de frutas tropicales.',
          'imagen': 'https://imag.bonviveur.com/ensalada-de-frutas.jpg',
          'precio': '\$60'
        },
      ],
    },
    {
      'title': 'Comidas',
      'image':
          'https://img.hellofresh.com/w_3840,q_auto,f_auto,c_fill,fl_lossy/hellofresh_s3/image/HF_Y24_R16_W42_ES_ESSGP30616-2_Main__edit_meat_high-a670615d.jpg',
      'items': [
        {
          'nombre': 'Pollo a la plancha',
          'descripcion': 'Con arroz y verduras salteadas.',
          'imagen':
              'https://i.pinimg.com/736x/36/10/4e/36104e7c7d7515da67f3c2dd2d1b215f.jpg',
          'precio': '\$90'
        },
        {
          'nombre': 'Tacos de Carne',
          'descripcion': 'Tortillas de maíz con carne asada y salsas.',
          'imagen':
              'https://familiakitchen.com/wp-content/uploads/2021/01/iStock-960337396-3beef-barbacoa-tacos-e1695391119564.jpg',
          'precio': '\$85'
        },
      ],
    },
    {
      'title': 'Bebidas',
      'image':
          'https://www.finedininglovers.com/es/sites/g/files/xknfdk1706/files/2022-05/bebidas-refrescantes-sin-alcohol%C2%A9iStock.jpg',
      'items': [
        {
          'nombre': 'Agua de Horchata',
          'descripcion': 'Refrescante bebida de arroz con canela.',
          'imagen':
              'https://amorfm.mx/wp-content/uploads/2019/01/aguadehorchata.jpg',
          'precio': '\$25'
        },
        {
          'nombre': 'Jugo de Naranja',
          'descripcion': 'Natural y recién exprimido.',
          'imagen':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPIkbP234NYEbkySr7kdlLLJvqbxzqGJjI2w&s',
          'precio': '\$30'
        },
      ],
    },
  ];

  MainPlatillosPage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Platillos del Día',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          CartButton(userData: userData),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      _mostrarSubcategorias(context, category);
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
                              child: Image.network(
                                category['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: secondaryColor.withOpacity(0.2),
                                    child: Center(
                                      child: Icon(
                                        Icons.fastfood,
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
                                      category['title'],
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
                                          '${category['items'].length} opciones',
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
                          categoria['title'],
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
                  itemCount: categoria['items'].length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = categoria['items'][index];
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
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item['imagen'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    color: primaryColor,
                                    size: 28,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        title: Text(
                          item['nombre'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          item['descripcion'],
                          style: TextStyle(fontSize: 13),
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
                            item['precio'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarDetallePlatillo(context, item);
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

  void _mostrarDetallePlatillo(
      BuildContext context, Map<String, dynamic> platillo) {
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
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      platillo['imagen'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 50,
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  platillo['nombre'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    platillo['descripcion'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    platillo['precio'],
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
                    onPressed: () {
                      try {
                        final cartController = Get.find<CartController>();
                        final precio = double.tryParse(platillo['precio']
                                .toString()
                                .replaceAll('\$', '')) ??
                            0.0;

                        print(
                            'Añadiendo al carrito: ${platillo['nombre']} - Precio: $precio');

                        final item = {
                          'nombre': platillo['nombre'],
                          'descripcion': platillo['descripcion'],
                          'precio': precio,
                          'imagen': platillo['imagen'],
                          'categoria': 'platillo',
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      'Añadir al carrito',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
