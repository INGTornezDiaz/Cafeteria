import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reporte Mensual',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ReporteMensualScreen(),
    );
  }
}

class ReporteMensualScreen extends StatelessWidget {
  const ReporteMensualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte Mensual'),
      ),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          final mes = [
            'Enero',
            'Febrero',
            'Marzo',
            'Abril',
            'Mayo',
            'Junio',
            'Julio',
            'Agosto',
            'Septiembre',
            'Octubre',
            'Noviembre',
            'Diciembre'
          ][index];
          return ListTile(
            title: Text('Reporte $mes'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReporteDetalleScreen(mes: mes),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ReporteDetalleScreen extends StatelessWidget {
  final String mes;

  const ReporteDetalleScreen({super.key, required this.mes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de $mes'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('No. Pedido')),
                  DataColumn(label: Text('Platillo')),
                  DataColumn(label: Text('Postre')),
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Subtotal')),
                  DataColumn(label: Text('Total')),
                ],
                rows: List.generate(
                  10,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text('Pedido ${index + 1}')),
                      DataCell(Text('Platillo ${index + 1}')),
                      DataCell(Text('Postre ${index + 1}')),
                      DataCell(Text('Cliente ${index + 1}')),
                      DataCell(Text('2023-10-${index + 1}')),
                      DataCell(Text('\$${(index + 1) * 10}.00')),
                      DataCell(Text('\$${(index + 1) * 12}.00')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Aquí puedes implementar la lógica para exportar a PDF
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exportando a PDF...')),
                  );
                },
                child: const Text('Exportar PDF'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
