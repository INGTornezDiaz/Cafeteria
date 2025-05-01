import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrderScreen(),
    );
  }
}

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tabla de pedidos
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: [
                    tableCell('Fecha', isHeader: true),
                    tableCell('Alimento', isHeader: true),
                    tableCell('Bebida', isHeader: true),
                    tableCell('Cant.', isHeader: true),
                    tableCell('Precio', isHeader: true),
                    tableCell('Total', isHeader: true),
                  ],
                ),
                tableRow(
                  '13/03/2025',
                  'Huevo',
                  'Té',
                  '1',
                  '40.00',
                ),
              ],
            ),
            SizedBox(height: 10),
            // Total a pagar
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total a pagar: \$50.00',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            // Comentarios
            TextField(
              decoration: InputDecoration(
                labelText: 'Comentarios',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                elevatedButton('Pedir', Colors.blue),
                elevatedButton('Cancelar', Colors.red),
                elevatedButton('Regresar', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow tableRow(String fecha, String producto, String cantidad,
      String precio, String total) {
    return TableRow(
      children: [
        tableCell(fecha),
        tableCell(producto),
        tableCell(cantidad),
        tableCell('\$$precio'),
        tableCell('\$$total'),
      ],
    );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget elevatedButton(String text, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: () {},
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}
