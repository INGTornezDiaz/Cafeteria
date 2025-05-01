import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: PlatillosHomePage(),
    );
  }
}

class PlatillosHomePage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Sopas',
      'image':
          'https://jetextramar.com/wp-content/uploads/2021/09/receta-fideo-grueso-empresa-de-alimentos-700x525.jpg',
      'route': SopasPage(),
    },
    {
      'title': 'Ensaladas',
      'image':
          'https://exoticfruitbox.com/wp-content/uploads/2017/01/ensalada-detox-con-frutas-tropicales-dos-800x533.jpg',
      'route': EnsaladasPage(),
    },
    {
      'title': 'Comidas',
      'image':
          'https://img.hellofresh.com/w_3840,q_auto,f_auto,c_fill,fl_lossy/hellofresh_s3/image/HF_Y24_R16_W42_ES_ESSGP30616-2_Main__edit_meat_high-a670615d.jpg',
      'route': ComidasPage(),
    },
    {
      'title': 'Bebidas',
      'image':
          'https://www.finedininglovers.com/es/sites/g/files/xknfdk1706/files/2022-05/bebidas-refrescantes-sin-alcohol%C2%A9iStock.jpg',
      'route': BebidasPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Platillos del Día', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => category['route']),
                );
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        category['image'],
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      category['title'],
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SopasPage extends StatelessWidget {
  final List<Map<String, String>> sopas = [
    {
      'nombre': 'Sopa de Verduras',
      'descripcion': 'Con zanahoria, papa, calabaza y elote.',
      'imagen':
          'https://mejorconsalud.as.com/wp-content/uploads/2018/07/sopa-verduras-1.jpg',
    },
    {
      'nombre': 'Crema de Elote',
      'descripcion': 'Suave y cremosa, ideal para el almuerzo.',
      'imagen': 'https://i.blogs.es/59dd70/crema-de-elote/1366_2000.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return buildPlatilloPage('Sopas', sopas, Colors.orangeAccent);
  }
}

class EnsaladasPage extends StatelessWidget {
  final List<Map<String, String>> ensaladas = [
    {
      'nombre': 'Ensalada César',
      'descripcion': 'Lechuga fresca con aderezo y crutones.',
      'imagen':
          'https://sarasellos.com/wp-content/uploads/2024/07/ensalada-cesar1-1024x684.jpg',
    },
    {
      'nombre': 'Ensalada de Frutas',
      'descripcion': 'Fresca mezcla de frutas tropicales.',
      'imagen': 'https://imag.bonviveur.com/ensalada-de-frutas.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return buildPlatilloPage('Ensaladas', ensaladas, Colors.greenAccent);
  }
}

class ComidasPage extends StatelessWidget {
  final List<Map<String, String>> comidas = [
    {
      'nombre': 'Pollo a la plancha',
      'descripcion': 'Con arroz y verduras salteadas.',
      'imagen':
          'https://i.pinimg.com/736x/36/10/4e/36104e7c7d7515da67f3c2dd2d1b215f.jpg',
    },
    {
      'nombre': 'Tacos de Carne',
      'descripcion': 'Tortillas de maíz con carne asada y salsas.',
      'imagen':
          'https://familiakitchen.com/wp-content/uploads/2021/01/iStock-960337396-3beef-barbacoa-tacos-e1695391119564.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return buildPlatilloPage('Comidas', comidas, Colors.redAccent);
  }
}

class BebidasPage extends StatelessWidget {
  final List<Map<String, String>> bebidas = [
    {
      'nombre': 'Agua de Horchata',
      'descripcion': 'Refrescante bebida de arroz con canela.',
      'imagen':
          'https://amorfm.mx/wp-content/uploads/2019/01/aguadehorchata.jpg',
    },
    {
      'nombre': 'Jugo de Naranja',
      'descripcion': 'Natural y recién exprimido.',
      'imagen':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPIkbP234NYEbkySr7kdlLLJvqbxzqGJjI2w&s',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return buildPlatilloPage('Bebidas', bebidas, Colors.lightBlueAccent);
  }
}

Widget buildPlatilloPage(
    String title, List<Map<String, String>> items, Color color) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: color,
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 40.0), // Baja el contenido
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item['imagen']!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(item['nombre']!,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['descripcion']!),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          );
        },
      ),
    ),
  );
}
