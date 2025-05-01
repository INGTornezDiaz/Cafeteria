import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Exportar PDF")),
        body: const ButtonSection(),
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  Future<void> _generatePDF(BuildContext context) async {
    try {
      final pdf = pw.Document();

      final now = DateTime.now();
      final formattedDate = DateFormat('dd/MM/yyyy').format(now);

      final ByteData imageData = await rootBundle.load('assets/logo.png');
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      final pw.ImageProvider imageProvider = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Mostrar la imagen real
                    pw.Image(
                      imageProvider,
                      width: 100,
                      height: 50,
                      fit: pw.BoxFit.contain,
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Reporte de pedidos diarios',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Fecha: $formattedDate',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(width: 100),
                  ],
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),

                // Contenido principal
                pw.Center(
                  child: pw.Text(
                    "Contenido del reporte de pedidos diarios...",
                    style: pw.TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          "${directory.path}/reporte_pedidos_${formattedDate.replaceAll('/', '-')}.pdf");
      await file.writeAsBytes(await pdf.save());

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF guardado en: ${file.path}"),
          action: SnackBarAction(
            label: "Abrir",
            onPressed: () => _openFile(file.path),
          ),
        ),
      );

      await _openFile(file.path);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al generar el PDF: $e")));
    }
  }

  Future<void> _openFile(String path) async {
    await OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _generatePDF(context),
            child: const Text("Exportar a PDF"),
          ),
        ],
      ),
    );
  }
}
