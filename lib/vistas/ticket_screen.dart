import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TicketScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String? userName;

  const TicketScreen({Key? key, required this.order, this.userName})
      : super(key: key);

  String _generateQrData() {
    final DateTime date = (order['timestamp'] is Timestamp)
        ? (order['timestamp'] as Timestamp).toDate()
        : DateTime.now();

    final String itemsList = (order['items'] as List<dynamic>? ?? [])
        .map((item) => '• ${item['nombre']} x${item['cantidad']}')
        .join('\n');

    // Obtener el nombre del solicitante
    String nombreSolicitante = '-';
    if (userName != null && userName!.isNotEmpty) {
      nombreSolicitante = userName!;
    } else if (order['Solicitante'] != null &&
        order['Solicitante'].toString().isNotEmpty) {
      nombreSolicitante = order['Solicitante'].toString();
    } else if (order['nombre'] != null &&
        order['nombre'].toString().isNotEmpty) {
      nombreSolicitante = order['nombre'].toString();
    }

    return '''
Pedido #${order['ID_Orden']?.toString() ?? order['id']?.toString() ?? '-'}
Solicitante: $nombreSolicitante
Fecha: ${_formatDate(date)}
Total: \$${order['Total']?.toStringAsFixed(2) ?? '0.00'}
Estado: ${_getStatusText(order['status'] ?? 'pending')}

Productos:
$itemsList''';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime date = (order['timestamp'] is Timestamp)
        ? (order['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    final List<dynamic> items = order['items'] ?? [];
    final String status = order['status'] ?? 'pending';
    final String idOrden =
        order['ID_Orden']?.toString() ?? order['id']?.toString() ?? '-';
    final String total = order['Total']?.toStringAsFixed(2) ?? '0.00';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiket de Pedido'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/tecnm.png', height: 50),
                    const SizedBox(width: 16),
                    Image.asset('assets/images/itms.png', height: 50),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Pedido #$idOrden',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Solicitante: ${userName ?? order['Solicitante'] ?? '-'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fecha/Hora: ${_formatDate(date)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(height: 32, thickness: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Productos:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item['nombre']}',
                            style: const TextStyle(fontSize: 15)),
                        Text('x${item['cantidad']}',
                            style: const TextStyle(fontSize: 15)),
                      ],
                    )),
                const Divider(height: 32, thickness: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('\$${order['Total']?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estado:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(_getStatusText(status),
                        style: TextStyle(
                            fontSize: 16, color: _getStatusColor(status))),
                  ],
                ),
                const SizedBox(height: 24),
                QrImageView(
                  data: _generateQrData(),
                  version: QrVersions.auto,
                  size: 120.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text('Muestre este tiket al recoger su pedido',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'preparing':
        return 'En preparación';
      case 'ready':
        return 'Listo para recoger';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
