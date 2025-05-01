import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.black),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Image.asset('windows/assets/image1.png', height: 150),
                SizedBox(height: 10),
                Text(
                  '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildMenuItem(
                  context,
                  'Café',
                  'windows/assets/cafe_negro.png',
                  'Seleccionar',
                  () => _showCoffeeVarieties(context),
                ),
                _buildMenuItem(
                  context,
                  'Desayuno',
                  'windows/assets/desayuno.png',
                  'Seleccionar',
                ),
                _buildMenuItem(
                  context,
                  'Comida',
                  'windows/assets/comida.jpeg',
                  'Seleccionar',
                ),
                _buildMenuItem(
                  context,
                  'Postre',
                  'windows/assets/postre.png',
                  'Seleccionar',
                ),
                _buildMenuItem(
                  context,
                  'Bebidas',
                  'windows/assets/bebidas.png',
                  'Seleccionar',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String imagePath,
    String buttonText, [
    VoidCallback? onTap,
  ]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, height: 80),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        ElevatedButton(
          onPressed: onTap ??
              () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$title seleccionado')));
              },
          child: Text(buttonText),
        ),
      ],
    );
  }

  // Método para mostrar las variedades de café en un Dialog
  void _showCoffeeVarieties(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Variedades de Café'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Café Espresso'),
                subtitle: Text('Café fuerte, perfecto para empezar el día.'),
              ),
              ListTile(
                title: Text('Café Latte'),
                subtitle: Text('Café suave con leche vaporizada.'),
              ),
              ListTile(
                title: Text('Café Mocha'),
                subtitle: Text(
                    'Café con chocolate, ideal para los amantes del dulce.'),
              ),
              ListTile(
                title: Text('Café Americano'),
                subtitle: Text('Café filtrado, ligero y suave.'),
              ),
              ListTile(
                title: Text('Café Capuccino'),
                subtitle: Text('Café con una capa espumosa de leche.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
