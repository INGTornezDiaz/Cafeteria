import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();
  final OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    // Obtener los datos del usuario de los argumentos de la ruta
    final userData = Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () {
              _showOrderHistory(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (cartController.cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart,
                          size: 60, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text('Tu carrito está vacío',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Agrega platillos deliciosos',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item['imagen'] != null &&
                                        item['imagen'].isNotEmpty
                                    ? Image.asset(
                                        item['imagen'],
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildPlaceholderIcon(),
                                      )
                                    : _buildPlaceholderIcon(),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nombre'] ?? 'Sin nombre',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      item['descripcion'] ?? 'Sin descripción',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '\$${(item['precio'] ?? 0.0).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        cartController.removeItem(item),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline,
                                            color: Colors.orange),
                                        onPressed: () {
                                          if ((item['cantidad'] ?? 1) > 1) {
                                            var updatedItem =
                                                Map<String, dynamic>.from(item);
                                            updatedItem['cantidad'] =
                                                (item['cantidad'] ?? 1) - 1;
                                            cartController.cartItems[index] =
                                                updatedItem;
                                          }
                                        },
                                      ),
                                      Text(
                                        '${item['cantidad'] ?? 1}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline,
                                            color: Colors.orange),
                                        onPressed: () {
                                          var updatedItem =
                                              Map<String, dynamic>.from(item);
                                          updatedItem['cantidad'] =
                                              (item['cantidad'] ?? 1) + 1;
                                          cartController.cartItems[index] =
                                              updatedItem;
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          _buildTotalSection(userData),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[200],
      child: Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  Widget _buildTotalSection(Map<String, dynamic>? userData) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Obx(() => Text(
                    '\$${cartController.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800]))),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: cartController.isLoading.value
                        ? null
                        : () => _confirmOrder(userData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: cartController.isLoading.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined),
                              SizedBox(width: 10),
                              Text('Realizar Pedido',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder(Map<String, dynamic>? userData) {
    if (userData == null) {
      Get.snackbar(
        'Error',
        'No se pudo obtener la información del usuario',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red[800]),
      );
      return;
    }

    if (cartController.cartItems.isEmpty) {
      Get.snackbar(
        'Error',
        'El carrito está vacío. Agrega productos antes de realizar el pedido.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red[800]),
      );
      return;
    }

    cartController.saveOrder(userData);
  }

  void _showOrderHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial de Pedidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_sweep),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text('Limpiar Historial'),
                          content: Text(
                              '¿Estás seguro de que deseas limpiar todo el historial de pedidos?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                orderController.clearHistory();
                                Get.back();
                              },
                              child: Text('Limpiar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: Obx(() {
                  if (orderController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (orderController.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history,
                              size: 60, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No hay pedidos en el historial',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: orderController.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderController.orders[index];
                      final status = order['status'] ?? 'pending';
                      final timestamp =
                          (order['timestamp'] as Timestamp?)?.toDate() ??
                              DateTime.now();

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child:
                                Icon(Icons.receipt_long, color: Colors.orange),
                          ),
                          title: Text('Pedido #${order['id']}'),
                          subtitle: Text(
                              'Fecha: ${timestamp.toString().split('.')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (status == 'pending' || status == 'preparing')
                                IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    Get.dialog(
                                      AlertDialog(
                                        title: Text('Cancelar Pedido'),
                                        content: Text(
                                            '¿Estás seguro de que deseas cancelar este pedido?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              orderController
                                                  .cancelOrder(order['id']);
                                              Get.back();
                                            },
                                            child: Text('Sí, cancelar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                          onTap: () {
                            Get.dialog(
                              AlertDialog(
                                title:
                                    Text('Detalles del Pedido #${order['id']}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Estado: ${_getStatusText(status)}'),
                                    Text(
                                        'Fecha: ${timestamp.toString().split('.')[0]}'),
                                    Text(
                                        'Total: \$${order['total']?.toStringAsFixed(2) ?? '0.00'}'),
                                    SizedBox(height: 10),
                                    Text('Items:'),
                                    ...(order['items'] as List<dynamic>? ?? [])
                                        .map((item) {
                                      return Text(
                                          '- ${item['nombre']} x ${item['cantidad']}');
                                    }).toList(),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('Cerrar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'preparing':
        return 'En preparación';
      case 'ready':
        return 'Listo';
      case 'completed':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  Color _getStatusColor(String status) {
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
        return Colors.grey;
    }
  }
}
