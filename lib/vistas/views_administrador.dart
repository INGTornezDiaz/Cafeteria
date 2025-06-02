import 'package:flutter/material.dart';
import 'admin_usuarios.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class AdministradorScreen extends StatelessWidget {
  // Colores como constantes estáticas
  static const Color primaryOrange = Color(0xFFFF7F11);
  static const Color secondaryOrange = Color(0xFFFFD700);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);

  final Map<String, dynamic> userData;

  const AdministradorScreen({Key? key, required this.userData})
      : super(key: key);

  Future<void> _cerrarSesion(BuildContext context) async {
    final bool? confirmacion = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: primaryOrange),
              SizedBox(width: 10),
              Text('Cerrar Sesión'),
            ],
          ),
          content: Text('¿Está seguro que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: primaryOrange),
              ),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Future<void> _mostrarDialogoRegistroChef(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _nombreController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.restaurant,
                              color: primaryOrange, size: 24),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Registrar Nuevo Chef',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nombreController,
                            decoration: InputDecoration(
                              labelText: 'Nombre Completo',
                              prefixIcon: Icon(Icons.person,
                                  color: primaryOrange, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el nombre';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Correo Electrónico',
                              prefixIcon: Icon(Icons.email,
                                  color: primaryOrange, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el correo';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Ingrese un correo válido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock,
                                  color: primaryOrange, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese la contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    SizedBox(width: 8),
                    _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryOrange,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  final userCredential = await FirebaseAuth
                                      .instance
                                      .createUserWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );

                                  await FirebaseFirestore.instance
                                      .collection('chefs')
                                      .doc(userCredential.user!.uid)
                                      .set({
                                    'Nombre': _nombreController.text.trim(),
                                    'Correo': _emailController.text.trim(),
                                    'PK_ROL': 2,
                                    'Usuario': _emailController.text.trim(),
                                    'Contrasena': _passwordController.text,
                                  });

                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Chef registrado exitosamente'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error al registrar chef: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: Text('Registrar'),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generarReporteDiario(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _fechaController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.assessment,
                              color: primaryOrange, size: 24),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Generar Reporte Diario',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _fechaController,
                            decoration: InputDecoration(
                              labelText: 'Fecha del Reporte',
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: primaryOrange, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _fechaController.text =
                                    DateFormat('yyyy-MM-dd').format(picked);
                              }
                            },
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Firma Electrónica',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Signature(
                              controller: _signatureController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () => _signatureController.clear(),
                                icon: Icon(Icons.delete, color: Colors.red),
                                label: Text('Limpiar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // Obtener las órdenes del día
                            final fecha =
                                _fechaController.text; // Formato: 2025-06-01
                            print(
                                'Buscando órdenes para la fecha: $fecha'); // Debug

                            // Convertir el formato de fecha para la búsqueda
                            final fechaFormateada = DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(fecha));
                            print(
                                'Fecha formateada para búsqueda: $fechaFormateada'); // Debug

                            // Buscar órdenes con el formato correcto (dd/MM/yyyy)
                            var ordenesSnapshot = await FirebaseFirestore
                                .instance
                                .collection('ordenes')
                                .where('Fecha', isEqualTo: fechaFormateada)
                                .get();

                            print(
                                'Órdenes encontradas para la fecha $fechaFormateada: ${ordenesSnapshot.docs.length}'); // Debug

                            if (ordenesSnapshot.docs.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'No hay órdenes registradas para esta fecha'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Crear el PDF
                            final pdf = pw.Document();
                            // Cargar los logos desde assets
                            final ByteData logoTecnmData = await rootBundle
                                .load('assets/images/tecnm.png');
                            final Uint8List logoTecnmBytes =
                                logoTecnmData.buffer.asUint8List();
                            final pw.ImageProvider logoTecnmProvider =
                                pw.MemoryImage(logoTecnmBytes);
                            final ByteData logoItmsData =
                                await rootBundle.load('assets/images/itms.png');
                            final Uint8List logoItmsBytes =
                                logoItmsData.buffer.asUint8List();
                            final pw.ImageProvider logoItmsProvider =
                                pw.MemoryImage(logoItmsBytes);
                            final image = await _signatureController.toImage();
                            if (image != null) {
                              final pngBytes = await image.toByteData(
                                  format: ui.ImageByteFormat.png);
                              if (pngBytes != null) {
                                final signatureImage = pw.MemoryImage(
                                    pngBytes.buffer.asUint8List());

                                // Obtener nombres reales de los solicitantes
                                List<Map<String, dynamic>>
                                    ordenesConSolicitante = [];
                                for (var doc in ordenesSnapshot.docs) {
                                  final data = doc.data();
                                  String solicitante = 'N/A';
                                  if (data['PK_Estudiante'] != null) {
                                    final estudianteSnap =
                                        await FirebaseFirestore
                                            .instance
                                            .collection('estudiantes')
                                            .doc(data['PK_Estudiante']
                                                .toString())
                                            .get();
                                    if (estudianteSnap.exists &&
                                        estudianteSnap.data() != null) {
                                      solicitante =
                                          estudianteSnap.data()!['Nombre'] ??
                                              'N/A';
                                    }
                                  } else if (data['PK_Docente'] != null) {
                                    final docenteSnap = await FirebaseFirestore
                                        .instance
                                        .collection('docentes')
                                        .doc(data['PK_Docente'].toString())
                                        .get();
                                    if (docenteSnap.exists &&
                                        docenteSnap.data() != null) {
                                      solicitante =
                                          docenteSnap.data()!['Nombre'] ??
                                              'N/A';
                                    }
                                  }
                                  ordenesConSolicitante.add({
                                    ...data,
                                    'SolicitanteNombre': solicitante
                                  });
                                }

                                // Calcular el total general
                                double totalGeneral = 0;
                                for (var data in ordenesConSolicitante) {
                                  totalGeneral += (data['Total'] is num)
                                      ? data['Total'].toDouble()
                                      : 0.0;
                                }
                                // Mapeo de estados a español mejorado
                                String estadoEnEspanol(String status) {
                                  switch (status.toLowerCase()) {
                                    case 'pending':
                                      return 'Pendiente';
                                    case 'completed':
                                    case 'ready':
                                      return 'Completado';
                                    case 'cancelled':
                                      return 'Cancelado';
                                    default:
                                      return status.isNotEmpty
                                          ? status[0].toUpperCase() +
                                              status.substring(1).toLowerCase()
                                          : '';
                                  }
                                }

                                pdf.addPage(
                                  pw.Page(
                                    pageFormat: PdfPageFormat.a4,
                                    margin: pw.EdgeInsets.all(32),
                                    build: (pw.Context context) {
                                      return pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.stretch,
                                        children: [
                                          // Logos alineados horizontalmente
                                          pw.Row(
                                            mainAxisAlignment: pw
                                                .MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Image(logoTecnmProvider,
                                                  width: 90, height: 90),
                                              pw.Image(logoItmsProvider,
                                                  width: 90, height: 90),
                                            ],
                                          ),
                                          pw.SizedBox(height: 10),
                                          // Encabezado institucional
                                          pw.Center(
                                            child: pw.Text(
                                              'TECNOLÓGICO NACIONAL DE MÉXICO',
                                              style: pw.TextStyle(
                                                fontSize: 16,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.blue800,
                                              ),
                                            ),
                                          ),
                                          pw.Center(
                                            child: pw.Text(
                                              'INSTITUTO TECNOLÓGICO DE SAN MARCOS',
                                              style: pw.TextStyle(
                                                fontSize: 15,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.blueGrey800,
                                              ),
                                            ),
                                          ),
                                          pw.SizedBox(height: 10),
                                          pw.Divider(thickness: 2),
                                          pw.SizedBox(height: 10),
                                          pw.Center(
                                            child: pw.Text(
                                              'Reporte Diario de Órdenes',
                                              style: pw.TextStyle(
                                                fontSize: 22,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                          ),
                                          pw.SizedBox(height: 8),
                                          pw.Center(
                                            child: pw.Text(
                                              'Fecha: $fechaFormateada',
                                              style: pw.TextStyle(
                                                  fontSize: 14,
                                                  color: PdfColors.grey700),
                                            ),
                                          ),
                                          pw.SizedBox(height: 20),
                                          pw.Table(
                                            border: pw.TableBorder.all(
                                                width: 1,
                                                color: PdfColors.blueGrey400),
                                            columnWidths: {
                                              0: pw.FlexColumnWidth(
                                                  1), // Número de orden
                                              1: pw.FlexColumnWidth(
                                                  2), // Productos
                                              2: pw.FlexColumnWidth(
                                                  1), // Solicitante
                                              3: pw.FlexColumnWidth(1), // Total
                                              4: pw.FlexColumnWidth(
                                                  1), // Estado
                                            },
                                            children: [
                                              pw.TableRow(
                                                decoration: pw.BoxDecoration(
                                                    color: PdfColors.blue100),
                                                children: [
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        'Número de orden',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                            fontSize: 12)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text('Productos',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                            fontSize: 12)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        'Solicitante',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                            fontSize: 12)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text('Total',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                            fontSize: 12)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text('Estado',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                            fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                              ...ordenesConSolicitante
                                                  .map((data) {
                                                // Productos: solo cantidad y nombre
                                                String productos = '';
                                                if (data['items'] is List) {
                                                  productos =
                                                      (data['items'] as List)
                                                          .map((item) {
                                                    final nombre =
                                                        item['nombre'] ?? '';
                                                    final cantidad =
                                                        item['cantidad'] ?? 1;
                                                    return '${cantidad}x $nombre';
                                                  }).join(', ');
                                                } else {
                                                  productos = [
                                                    data['Platillo'],
                                                    data['Bebidas'],
                                                    data['Postre']
                                                  ]
                                                      .where((e) =>
                                                          e != null &&
                                                          e
                                                              .toString()
                                                              .isNotEmpty)
                                                      .join(', ');
                                                }
                                                return pw.TableRow(
                                                  children: [
                                                    pw.Padding(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      child: pw.Text(
                                                          data['ID_Orden']
                                                                  ?.toString() ??
                                                              'N/A',
                                                          style: pw.TextStyle(
                                                              fontSize: 11)),
                                                    ),
                                                    pw.Padding(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      child: pw.Text(productos,
                                                          style: pw.TextStyle(
                                                              fontSize: 11)),
                                                    ),
                                                    pw.Padding(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      child: pw.Text(
                                                          data['SolicitanteNombre'] ??
                                                              'N/A',
                                                          style: pw.TextStyle(
                                                              fontSize: 11)),
                                                    ),
                                                    pw.Padding(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      child: pw.Text(
                                                          '\$${data['Total']?.toStringAsFixed(2) ?? '0.00'}',
                                                          style: pw.TextStyle(
                                                              fontSize: 11)),
                                                    ),
                                                    pw.Padding(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      child: pw.Text(
                                                          estadoEnEspanol(
                                                              data['status'] ??
                                                                  ''),
                                                          style: pw.TextStyle(
                                                              fontSize: 11)),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          pw.SizedBox(height: 20),
                                          // Total general
                                          pw.Row(
                                            mainAxisAlignment:
                                                pw.MainAxisAlignment.end,
                                            children: [
                                              pw.Text('Total del día: ',
                                                  style: pw.TextStyle(
                                                      fontWeight:
                                                          pw.FontWeight.bold,
                                                      fontSize: 13)),
                                              pw.Text(
                                                  '\$${totalGeneral.toStringAsFixed(2)}',
                                                  style: pw.TextStyle(
                                                      fontWeight:
                                                          pw.FontWeight.bold,
                                                      fontSize: 13,
                                                      color:
                                                          PdfColors.green800)),
                                            ],
                                          ),
                                          pw.SizedBox(height: 30),
                                          pw.Row(
                                            mainAxisAlignment: pw
                                                .MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Column(
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('Firma Electrónica',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight
                                                              .bold)),
                                                  pw.SizedBox(height: 10),
                                                  pw.Image(signatureImage,
                                                      height: 100),
                                                ],
                                              ),
                                              pw.Column(
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.end,
                                                children: [
                                                  pw.Text('Director',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight
                                                              .bold)),
                                                  pw.Text(
                                                      'Victor Hugo Agaton Catalan'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );

                                // Guardar y compartir el PDF
                                final output = await getTemporaryDirectory();
                                final file = File(
                                    '${output.path}/reporte_diario_$fecha.pdf');
                                await file.writeAsBytes(await pdf.save());
                                await Share.shareXFiles([XFile(file.path)]);

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Reporte generado exitosamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Por favor, agregue una firma al reporte'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error al generar el reporte: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Generar PDF'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generarReporteMensual(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    int selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month;
    final _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf,
                              color: primaryOrange, size: 24),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Generar Reporte Mensual',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedMonth,
                        decoration: InputDecoration(
                          labelText: 'Mes',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(12, (index) => index + 1)
                            .map((month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(DateFormat.MMMM('es_MX')
                                      .format(DateTime(0, month))),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null)
                            setState(() => selectedMonth = value);
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedYear,
                        decoration: InputDecoration(
                          labelText: 'Año',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                                6, (index) => DateTime.now().year - index)
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null)
                            setState(() => selectedYear = value);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Firma Electrónica',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _signatureController.clear(),
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Limpiar'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          // Buscar todas las órdenes del mes y año seleccionados
                          final primerDia =
                              DateTime(selectedYear, selectedMonth, 1);
                          final ultimoDia =
                              DateTime(selectedYear, selectedMonth + 1, 0);
                          final DateFormat formato = DateFormat('dd/MM/yyyy');
                          final diasDelMes = List.generate(
                              ultimoDia.day,
                              (i) => formato.format(DateTime(
                                  selectedYear, selectedMonth, i + 1)));
                          final ordenesSnapshot = await FirebaseFirestore
                              .instance
                              .collection('ordenes')
                              .where('Fecha', whereIn: diasDelMes)
                              .get();
                          if (ordenesSnapshot.docs.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'No hay órdenes registradas para este mes'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          // Obtener nombres reales de los solicitantes
                          List<Map<String, dynamic>> ordenesConSolicitante = [];
                          for (var doc in ordenesSnapshot.docs) {
                            final data = doc.data();
                            String solicitante = 'N/A';
                            if (data['PK_Estudiante'] != null) {
                              final estudianteSnap = await FirebaseFirestore
                                  .instance
                                  .collection('estudiantes')
                                  .doc(data['PK_Estudiante'].toString())
                                  .get();
                              if (estudianteSnap.exists &&
                                  estudianteSnap.data() != null) {
                                solicitante =
                                    estudianteSnap.data()!['Nombre'] ?? 'N/A';
                              }
                            } else if (data['PK_Docente'] != null) {
                              final docenteSnap = await FirebaseFirestore
                                  .instance
                                  .collection('docentes')
                                  .doc(data['PK_Docente'].toString())
                                  .get();
                              if (docenteSnap.exists &&
                                  docenteSnap.data() != null) {
                                solicitante =
                                    docenteSnap.data()!['Nombre'] ?? 'N/A';
                              }
                            }
                            ordenesConSolicitante.add(
                                {...data, 'SolicitanteNombre': solicitante});
                          }
                          // Calcular el total general
                          double totalGeneral = 0;
                          for (var data in ordenesConSolicitante) {
                            totalGeneral += (data['Total'] is num)
                                ? data['Total'].toDouble()
                                : 0.0;
                          }
                          String estadoEnEspanol(String status) {
                            switch (status.toLowerCase()) {
                              case 'pending':
                                return 'Pendiente';
                              case 'completed':
                              case 'ready':
                                return 'Completado';
                              case 'cancelled':
                                return 'Cancelado';
                              default:
                                return status.isNotEmpty
                                    ? status[0].toUpperCase() +
                                        status.substring(1).toLowerCase()
                                    : '';
                            }
                          }

                          // Crear el PDF
                          final pdf = pw.Document();
                          final ByteData logoTecnmData =
                              await rootBundle.load('assets/images/tecnm.png');
                          final Uint8List logoTecnmBytes =
                              logoTecnmData.buffer.asUint8List();
                          final pw.ImageProvider logoTecnmProvider =
                              pw.MemoryImage(logoTecnmBytes);
                          final ByteData logoItmsData =
                              await rootBundle.load('assets/images/itms.png');
                          final Uint8List logoItmsBytes =
                              logoItmsData.buffer.asUint8List();
                          final pw.ImageProvider logoItmsProvider =
                              pw.MemoryImage(logoItmsBytes);
                          final image = await _signatureController.toImage();
                          if (image != null) {
                            final pngBytes = await image.toByteData(
                                format: ui.ImageByteFormat.png);
                            if (pngBytes != null) {
                              final signatureImage =
                                  pw.MemoryImage(pngBytes.buffer.asUint8List());
                              pdf.addPage(
                                pw.Page(
                                  pageFormat: PdfPageFormat.a4,
                                  margin: pw.EdgeInsets.all(32),
                                  build: (pw.Context context) {
                                    return pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
                                      children: [
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Image(logoTecnmProvider,
                                                width: 90, height: 90),
                                            pw.Image(logoItmsProvider,
                                                width: 90, height: 90),
                                          ],
                                        ),
                                        pw.SizedBox(height: 10),
                                        pw.Center(
                                          child: pw.Text(
                                            'TECNOLÓGICO NACIONAL DE MÉXICO',
                                            style: pw.TextStyle(
                                              fontSize: 16,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.blue800,
                                            ),
                                          ),
                                        ),
                                        pw.Center(
                                          child: pw.Text(
                                            'INSTITUTO TECNOLÓGICO DE SAN MARCOS',
                                            style: pw.TextStyle(
                                              fontSize: 15,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.blueGrey800,
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(height: 10),
                                        pw.Divider(thickness: 2),
                                        pw.SizedBox(height: 10),
                                        pw.Center(
                                          child: pw.Text(
                                            'Reporte Mensual de Órdenes',
                                            style: pw.TextStyle(
                                              fontSize: 22,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(height: 8),
                                        pw.Center(
                                          child: pw.Text(
                                            'Mes: ' +
                                                DateFormat.MMMM('es_MX').format(
                                                    DateTime(selectedYear,
                                                        selectedMonth)) +
                                                ' $selectedYear',
                                            style: pw.TextStyle(
                                                fontSize: 14,
                                                color: PdfColors.grey700),
                                          ),
                                        ),
                                        pw.SizedBox(height: 20),
                                        pw.Table(
                                          border: pw.TableBorder.all(
                                              width: 1,
                                              color: PdfColors.blueGrey400),
                                          columnWidths: {
                                            0: pw.FlexColumnWidth(
                                                1), // Número de orden
                                            1: pw.FlexColumnWidth(
                                                2), // Productos
                                            2: pw.FlexColumnWidth(
                                                1), // Solicitante
                                            3: pw.FlexColumnWidth(1), // Total
                                            4: pw.FlexColumnWidth(1), // Estado
                                          },
                                          children: [
                                            pw.TableRow(
                                              decoration: pw.BoxDecoration(
                                                  color: PdfColors.blue100),
                                              children: [
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text(
                                                      'Número de orden',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text('Productos',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text('Solicitante',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text('Total',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text('Estado',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            ...ordenesConSolicitante
                                                .map((data) {
                                              // Productos: solo cantidad y nombre
                                              String productos = '';
                                              if (data['items'] is List) {
                                                productos =
                                                    (data['items'] as List)
                                                        .map((item) {
                                                  final nombre =
                                                      item['nombre'] ?? '';
                                                  final cantidad =
                                                      item['cantidad'] ?? 1;
                                                  return '${cantidad}x $nombre';
                                                }).join(', ');
                                              } else {
                                                productos = [
                                                  data['Platillo'],
                                                  data['Bebidas'],
                                                  data['Postre']
                                                ]
                                                    .where((e) =>
                                                        e != null &&
                                                        e.toString().isNotEmpty)
                                                    .join(', ');
                                              }
                                              return pw.TableRow(
                                                children: [
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        data['ID_Orden']
                                                                ?.toString() ??
                                                            'N/A',
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(productos,
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        data['SolicitanteNombre'] ??
                                                            'N/A',
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        '\$${data['Total']?.toStringAsFixed(2) ?? '0.00'}',
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        estadoEnEspanol(
                                                            data['status'] ??
                                                                ''),
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                        pw.SizedBox(height: 20),
                                        // Total general
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.end,
                                          children: [
                                            pw.Text('Total del mes: ',
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 13)),
                                            pw.Text(
                                                '\$${totalGeneral.toStringAsFixed(2)}',
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 13,
                                                    color: PdfColors.green800)),
                                          ],
                                        ),
                                        pw.SizedBox(height: 30),
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text('Firma Electrónica',
                                                    style: pw.TextStyle(
                                                        fontWeight: pw
                                                            .FontWeight.bold)),
                                                pw.SizedBox(height: 10),
                                                pw.Image(signatureImage,
                                                    height: 100),
                                              ],
                                            ),
                                            pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.end,
                                              children: [
                                                pw.Text('Director',
                                                    style: pw.TextStyle(
                                                        fontWeight: pw
                                                            .FontWeight.bold)),
                                                pw.Text(
                                                    'Victor Hugo Agaton Catalan'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                              // Guardar y compartir el PDF
                              final output = await getTemporaryDirectory();
                              final file = File(
                                  '${output.path}/reporte_mensual_${selectedYear}_${selectedMonth.toString().padLeft(2, '0')}.pdf');
                              await file.writeAsBytes(await pdf.save());
                              await Share.shareXFiles([XFile(file.path)]);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Reporte mensual generado exitosamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Por favor, agregue una firma al reporte'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al generar el reporte: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Generar PDF'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generarReporteSemanal(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    final _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf,
                              color: primaryOrange, size: 24),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Generar Reporte Semanal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Selecciona una fecha de la semana',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: DateFormat('dd/MM/yyyy').format(selectedDate),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null)
                            setState(() => selectedDate = picked);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Firma Electrónica',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _signatureController.clear(),
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Limpiar'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          // Calcular el rango de la semana (lunes a domingo)
                          final int weekday = selectedDate.weekday;
                          final DateTime monday = selectedDate
                              .subtract(Duration(days: weekday - 1));
                          final DateTime sunday = monday.add(Duration(days: 6));
                          final DateFormat formato = DateFormat('dd/MM/yyyy');
                          final diasSemana = List.generate(
                              7,
                              (i) => formato
                                  .format(monday.add(Duration(days: i))));
                          final ordenesSnapshot = await FirebaseFirestore
                              .instance
                              .collection('ordenes')
                              .where('Fecha', whereIn: diasSemana)
                              .get();
                          if (ordenesSnapshot.docs.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'No hay órdenes registradas para esta semana'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          // Obtener nombres reales de los solicitantes
                          List<Map<String, dynamic>> ordenesConSolicitante = [];
                          for (var doc in ordenesSnapshot.docs) {
                            final data = doc.data();
                            String solicitante = 'N/A';
                            if (data['PK_Estudiante'] != null) {
                              final estudianteSnap = await FirebaseFirestore
                                  .instance
                                  .collection('estudiantes')
                                  .doc(data['PK_Estudiante'].toString())
                                  .get();
                              if (estudianteSnap.exists &&
                                  estudianteSnap.data() != null) {
                                solicitante =
                                    estudianteSnap.data()!['Nombre'] ?? 'N/A';
                              }
                            } else if (data['PK_Docente'] != null) {
                              final docenteSnap = await FirebaseFirestore
                                  .instance
                                  .collection('docentes')
                                  .doc(data['PK_Docente'].toString())
                                  .get();
                              if (docenteSnap.exists &&
                                  docenteSnap.data() != null) {
                                solicitante =
                                    docenteSnap.data()!['Nombre'] ?? 'N/A';
                              }
                            }
                            ordenesConSolicitante.add(
                                {...data, 'SolicitanteNombre': solicitante});
                          }
                          // Calcular el total general
                          double totalGeneral = 0;
                          for (var data in ordenesConSolicitante) {
                            totalGeneral += (data['Total'] is num)
                                ? data['Total'].toDouble()
                                : 0.0;
                          }
                          String estadoEnEspanol(String status) {
                            switch (status.toLowerCase()) {
                              case 'pending':
                                return 'Pendiente';
                              case 'completed':
                              case 'ready':
                                return 'Completado';
                              case 'cancelled':
                                return 'Cancelado';
                              default:
                                return status.isNotEmpty
                                    ? status[0].toUpperCase() +
                                        status.substring(1).toLowerCase()
                                    : '';
                            }
                          }

                          // Crear el PDF
                          final pdf = pw.Document();
                          final ByteData logoTecnmData =
                              await rootBundle.load('assets/images/tecnm.png');
                          final Uint8List logoTecnmBytes =
                              logoTecnmData.buffer.asUint8List();
                          final pw.ImageProvider logoTecnmProvider =
                              pw.MemoryImage(logoTecnmBytes);
                          final ByteData logoItmsData =
                              await rootBundle.load('assets/images/itms.png');
                          final Uint8List logoItmsBytes =
                              logoItmsData.buffer.asUint8List();
                          final pw.ImageProvider logoItmsProvider =
                              pw.MemoryImage(logoItmsBytes);
                          final image = await _signatureController.toImage();
                          if (image != null) {
                            final pngBytes = await image.toByteData(
                                format: ui.ImageByteFormat.png);
                            if (pngBytes != null) {
                              final signatureImage =
                                  pw.MemoryImage(pngBytes.buffer.asUint8List());
                              pdf.addPage(
                                pw.Page(
                                  pageFormat: PdfPageFormat.a4,
                                  margin: pw.EdgeInsets.all(32),
                                  build: (pw.Context context) {
                                    return pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.stretch,
                                      children: [
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Image(logoTecnmProvider,
                                                width: 90, height: 90),
                                            pw.Image(logoItmsProvider,
                                                width: 90, height: 90),
                                          ],
                                        ),
                                        pw.SizedBox(height: 10),
                                        pw.Center(
                                          child: pw.Text(
                                            'TECNOLÓGICO NACIONAL DE MÉXICO',
                                            style: pw.TextStyle(
                                              fontSize: 16,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.blue800,
                                            ),
                                          ),
                                        ),
                                        pw.Center(
                                          child: pw.Text(
                                            'INSTITUTO TECNOLÓGICO DE SAN MARCOS',
                                            style: pw.TextStyle(
                                              fontSize: 15,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.blueGrey800,
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(height: 10),
                                        pw.Divider(thickness: 2),
                                        pw.SizedBox(height: 10),
                                        pw.Center(
                                          child: pw.Text(
                                            'Reporte Semanal de Órdenes',
                                            style: pw.TextStyle(
                                              fontSize: 22,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(height: 8),
                                        pw.Center(
                                          child: pw.Text(
                                            'Semana: ' +
                                                formato.format(monday) +
                                                ' al ' +
                                                formato.format(sunday),
                                            style: pw.TextStyle(
                                                fontSize: 14,
                                                color: PdfColors.grey700),
                                          ),
                                        ),
                                        pw.SizedBox(height: 20),
                                        pw.Table(
                                          border: pw.TableBorder.all(
                                              width: 1,
                                              color: PdfColors.blueGrey400),
                                          columnWidths: {
                                            0: pw.FlexColumnWidth(
                                                1), // Número de orden
                                            1: pw.FlexColumnWidth(
                                                2), // Productos
                                            2: pw.FlexColumnWidth(
                                                1), // Solicitante
                                            3: pw.FlexColumnWidth(1), // Total
                                            4: pw.FlexColumnWidth(1), // Estado
                                          },
                                          children: [
                                            pw.TableRow(
                                              decoration: pw.BoxDecoration(
                                                  color: PdfColors.blue100),
                                              children: [
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text(
                                                      'Número de orden',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text('Productos',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text('Solicitante',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text('Total',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                                pw.Padding(
                                                  padding: pw.EdgeInsets.all(8),
                                                  child: pw.Text('Estado',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                            ...ordenesConSolicitante
                                                .map((data) {
                                              // Productos: solo cantidad y nombre
                                              String productos = '';
                                              if (data['items'] is List) {
                                                productos =
                                                    (data['items'] as List)
                                                        .map((item) {
                                                  final nombre =
                                                      item['nombre'] ?? '';
                                                  final cantidad =
                                                      item['cantidad'] ?? 1;
                                                  return '${cantidad}x $nombre';
                                                }).join(', ');
                                              } else {
                                                productos = [
                                                  data['Platillo'],
                                                  data['Bebidas'],
                                                  data['Postre']
                                                ]
                                                    .where((e) =>
                                                        e != null &&
                                                        e.toString().isNotEmpty)
                                                    .join(', ');
                                              }
                                              return pw.TableRow(
                                                children: [
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        data['ID_Orden']
                                                                ?.toString() ??
                                                            'N/A',
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(productos,
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        data['SolicitanteNombre'] ??
                                                            'N/A',
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        '\$${data['Total']?.toStringAsFixed(2) ?? '0.00'}',
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.all(8),
                                                    child: pw.Text(
                                                        estadoEnEspanol(
                                                            data['status'] ??
                                                                ''),
                                                        style: pw.TextStyle(
                                                            fontSize: 11)),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                        pw.SizedBox(height: 20),
                                        // Total general
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.end,
                                          children: [
                                            pw.Text('Total de la semana: ',
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 13)),
                                            pw.Text(
                                                '\$${totalGeneral.toStringAsFixed(2)}',
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 13,
                                                    color: PdfColors.green800)),
                                          ],
                                        ),
                                        pw.SizedBox(height: 30),
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text('Firma Electrónica',
                                                    style: pw.TextStyle(
                                                        fontWeight: pw
                                                            .FontWeight.bold)),
                                                pw.SizedBox(height: 10),
                                                pw.Image(signatureImage,
                                                    height: 100),
                                              ],
                                            ),
                                            pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.end,
                                              children: [
                                                pw.Text('Director',
                                                    style: pw.TextStyle(
                                                        fontWeight: pw
                                                            .FontWeight.bold)),
                                                pw.Text(
                                                    'Victor Hugo Agaton Catalan'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                              // Guardar y compartir el PDF
                              final output = await getTemporaryDirectory();
                              final file = File(
                                  '${output.path}/reporte_semanal_${DateFormat('yyyy_MM_dd').format(monday)}.pdf');
                              await file.writeAsBytes(await pdf.save());
                              await Share.shareXFiles([XFile(file.path)]);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Reporte semanal generado exitosamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Por favor, agregue una firma al reporte'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al generar el reporte: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Generar PDF'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        title: Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.account_circle,
                          size: 30, color: primaryOrange),
                      SizedBox(width: 10),
                      Text('Perfil de Usuario'),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.admin_panel_settings,
                              color: primaryOrange),
                          title: Text('Rol: Administrador',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ListTile(
                          leading: Icon(Icons.email, color: primaryOrange),
                          title: Text('Correo: ${userData['Correo']}'),
                        ),
                        ListTile(
                          leading: Icon(Icons.person, color: primaryOrange),
                          title: Text('Usuario: ${userData['Usuario']}'),
                        ),
                        if (userData['Nombre'] != null)
                          ListTile(
                            leading: Icon(Icons.badge, color: primaryOrange),
                            title: Text('Nombre: ${userData['Nombre']}'),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: primaryOrange),
                      label: Text('Cerrar',
                          style: TextStyle(color: primaryOrange)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [primaryOrange, secondaryOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings,
                          size: 40, color: primaryOrange),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Bienvenido Administrador',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userData['Usuario'],
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _buildMenuCard(
                  context,
                  'Gestionar Usuarios',
                  Icons.people,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminUsuariosScreen()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Registrar Chef',
                  Icons.restaurant,
                  () => _mostrarDialogoRegistroChef(context),
                ),
                _buildMenuCard(
                  context,
                  'Gestionar Menú',
                  Icons.restaurant_menu,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GestionMenuScreen())),
                ),
                _buildMenuCard(
                  context,
                  'Reportes Semanales',
                  Icons.calendar_view_week,
                  () => _generarReporteSemanal(context),
                ),
                _buildMenuCard(
                  context,
                  'Reportes Mensuales',
                  Icons.calendar_month,
                  () => _generarReporteMensual(context),
                ),
                _buildMenuCard(
                  context,
                  'Reportes Diarios',
                  Icons.calendar_today,
                  () => _generarReporteDiario(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: primaryOrange),
              ),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GestionMenuScreen extends StatefulWidget {
  @override
  _GestionMenuScreenState createState() => _GestionMenuScreenState();
}

class _GestionMenuScreenState extends State<GestionMenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categorias = ['platillos', 'bebidas', 'postres'];
  String _selectedCategoria = 'platillos';
  final _storageService = StorageService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategoria = categorias[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Menú'),
        backgroundColor: AdministradorScreen.primaryOrange,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Platillos'),
            Tab(text: 'Bebidas'),
            Tab(text: 'Postres'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categorias
                  .map((categoria) => _buildListaCategoria(categoria))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCategoria(String categoria) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(categoria).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay productos en esta categoría.'));
        }
        final productos = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _searchQuery.isEmpty ||
              (data['Nombre'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
        }).toList();
        return ListView.builder(
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final data = productos[index].data() as Map<String, dynamic>;
            final docId = productos[index].id;
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<File?>(
                      future: () {
                        final img = data['Imagen'] ?? data['imagen'];
                        return (img != null && img.toString().isNotEmpty)
                            ? _storageService.getImageFile(img, categoria)
                            : Future.value(null);
                      }(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            width: 70,
                            height: 70,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(snapshot.data!,
                                width: 70, height: 70, fit: BoxFit.cover),
                          );
                        }
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.fastfood,
                              size: 40,
                              color: AdministradorScreen.primaryOrange),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['Nombre'] ?? data['nombre'] ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          if ((data['Descripcion'] ?? data['descripcion']) !=
                                  null &&
                              (data['Descripcion'] ?? data['descripcion'])
                                  .toString()
                                  .isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                  data['Descripcion'] ?? data['descripcion'],
                                  style: TextStyle(color: Colors.grey[700])),
                            ),
                          SizedBox(height: 4),
                          Wrap(
                            spacing: 12,
                            children: [
                              Text(
                                  'Precio: \$${(data['Precio'] ?? data['precio'])?.toStringAsFixed(2) ?? (data['Precio'] ?? data['precio'] ?? '0.00')}',
                                  style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.w500)),
                              if ((data['cantidad'] ?? data['Cantidad']) !=
                                  null)
                                Text(
                                    'Cantidad: ${data['cantidad'] ?? data['Cantidad']}'),
                              if ((data['tipo'] ?? data['Tipo']) != null)
                                Text('Tipo: ${data['tipo'] ?? data['Tipo']}'),
                              if ((data['categoria'] ?? data['Categoria']) !=
                                  null)
                                Text(
                                    'Categoría: ${data['categoria'] ?? data['Categoria']}'),
                              Text(
                                  'Disponible: ${(data['Disponible'] ?? data['disponible']) == true ? 'Sí' : 'No'}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarFormularioProducto(context,
                              categoria: categoria, docId: docId, data: data),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminarProducto(
                              context, categoria, docId),
                        ),
                        Switch(
                          value: (data['Disponible'] ?? data['disponible']) ==
                              true,
                          onChanged: (value) => _actualizarDisponibilidad(
                              categoria, docId, value),
                          activeColor: AdministradorScreen.primaryOrange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarFormularioProducto(BuildContext context,
      {required String categoria,
      String? docId,
      Map<String, dynamic>? data}) async {
    final _formKey = GlobalKey<FormState>();
    final nombreController =
        TextEditingController(text: data?['Nombre'] ?? data?['nombre'] ?? '');
    final descripcionController = TextEditingController(
        text: data?['Descripcion'] ?? data?['descripcion'] ?? '');
    final precioController = TextEditingController(
        text: (data?['Precio'] ?? data?['precio'])?.toString() ?? '');
    final cantidadController = TextEditingController(
        text: (data?['cantidad'] ?? data?['Cantidad'])?.toString() ?? '');
    final tipoController =
        TextEditingController(text: data?['tipo'] ?? data?['Tipo'] ?? '');
    final categoriaController = TextEditingController(
        text: data?['categoria'] ?? data?['Categoria'] ?? '');
    String? imagenUrl = data?['Imagen'] ?? data?['imagen'];
    bool disponible = (data?['Disponible'] ?? data?['disponible']) ?? true;
    XFile? nuevaImagen;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(docId == null ? 'Agregar Producto' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() => nuevaImagen = picked);
                      }
                    },
                    child: nuevaImagen != null
                        ? Image.file(File(nuevaImagen!.path),
                            width: 100, height: 100, fit: BoxFit.cover)
                        : (imagenUrl != null && imagenUrl.isNotEmpty)
                            ? FutureBuilder<File?>(
                                future: _storageService.getImageFile(
                                    imagenUrl, categoria),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(
                                        width: 100,
                                        height: 100,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator()));
                                  }
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Image.file(snapshot.data!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover);
                                  }
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.add_a_photo,
                                        size: 40, color: Colors.grey),
                                  );
                                },
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: Icon(Icons.add_a_photo,
                                    size: 40, color: Colors.grey),
                              ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingrese el nombre' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: descripcionController,
                    decoration: InputDecoration(labelText: 'Descripción'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: precioController,
                    decoration: InputDecoration(labelText: 'Precio'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingrese el precio' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: cantidadController,
                    decoration: InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: tipoController,
                    decoration: InputDecoration(labelText: 'Tipo'),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: categoriaController,
                    decoration: InputDecoration(labelText: 'Categoría'),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Disponible'),
                      Switch(
                        value: disponible,
                        onChanged: (value) =>
                            setState(() => disponible = value),
                        activeColor: AdministradorScreen.primaryOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String? url = imagenUrl;
                  if (nuevaImagen != null) {
                    // Aquí deberías subir la imagen a Firebase Storage y obtener la URL
                    // Por simplicidad, solo guardamos el path local
                    url = nuevaImagen!.path;
                  }
                  final producto = {
                    'Nombre': nombreController.text.trim(),
                    'Descripcion': descripcionController.text.trim(),
                    'Precio': double.tryParse(precioController.text) ?? 0.0,
                    'Imagen': url ?? '',
                    'Disponible': disponible,
                    'cantidad': int.tryParse(cantidadController.text) ?? 0,
                    'tipo': tipoController.text.trim(),
                    'categoria': categoriaController.text.trim(),
                  };
                  if (docId == null) {
                    await FirebaseFirestore.instance
                        .collection(categoria)
                        .add(producto);
                  } else {
                    await FirebaseFirestore.instance
                        .collection(categoria)
                        .doc(docId)
                        .update(producto);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(docId == null ? 'Agregar' : 'Guardar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdministradorScreen.primaryOrange),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminarProducto(
      BuildContext context, String categoria, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Producto'),
        content: Text('¿Está seguro de eliminar este producto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection(categoria)
          .doc(docId)
          .delete();
    }
  }

  Future<void> _actualizarDisponibilidad(
      String categoria, String docId, bool disponible) async {
    await FirebaseFirestore.instance
        .collection(categoria)
        .doc(docId)
        .update({'Disponible': disponible});
  }
}
