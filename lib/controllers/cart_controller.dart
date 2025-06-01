import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartController extends GetxController {
  final _items = <Map<String, dynamic>>[].obs;
  final _total = 0.0.obs;
  var isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters para mantener compatibilidad
  List<Map<String, dynamic>> get cartItems => _items;
  double get totalPrice => _total.value;
  List<Map<String, dynamic>> get items => _items;
  double get total => _total.value;

  // Getter para el conteo total de items
  int get itemCount =>
      _items.fold(0, (sum, item) => sum + (item['cantidad'] as int? ?? 1));

  @override
  void onInit() {
    super.onInit();
    print('CartController inicializado');
    // Agregar un listener para ver cuando cambian los items
    ever(_items, (_) {
      print('CartItems actualizado: ${_items.length} items');
      print('Contenido del carrito: ${_items.toString()}');
      _calcularTotal();
    });
  }

  // Método para mantener compatibilidad
  void addItem(Map<String, dynamic> item) {
    final existingItemIndex =
        _items.indexWhere((i) => i['nombre'] == item['nombre']);

    if (existingItemIndex >= 0) {
      _items[existingItemIndex]['cantidad'] =
          (_items[existingItemIndex]['cantidad'] ?? 0) + 1;
    } else {
      item['cantidad'] = 1;
      _items.add(item);
    }

    _calcularTotal();
  }

  // Nuevo método con parámetros nombrados
  void addToCart({
    required String id,
    required String nombre,
    required double precio,
    String? imagenUrl,
    required String tipo,
  }) {
    final existingItemIndex = _items.indexWhere((item) => item['id'] == id);

    if (existingItemIndex >= 0) {
      _items[existingItemIndex]['cantidad'] =
          (_items[existingItemIndex]['cantidad'] ?? 0) + 1;
    } else {
      _items.add({
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'cantidad': 1,
        'imagenUrl': imagenUrl,
        'tipo': tipo,
      });
    }

    _calcularTotal();
  }

  // Método para mantener compatibilidad
  void removeItem(Map<String, dynamic> item) {
    _items.remove(item);
    _calcularTotal();
  }

  // Nuevo método con ID
  void removeFromCart(String id) {
    _items.removeWhere((item) => item['id'] == id);
    _calcularTotal();
  }

  void updateQuantity(String id, int cantidad) {
    final index = _items.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      if (cantidad > 0) {
        _items[index]['cantidad'] = cantidad;
      } else {
        _items.removeAt(index);
      }
      _calcularTotal();
    }
  }

  void _calcularTotal() {
    _total.value = _items.fold(0.0, (sum, item) {
      return sum + (item['precio'] * (item['cantidad'] ?? 1));
    });
  }

  void clearCart() {
    _items.clear();
    _total.value = 0.0;
  }

  Future<void> saveOrder(Map<String, dynamic> usuario) async {
    try {
      isLoading.value = true;
      print('Guardando pedido para usuario: ${usuario['nombre']}');
      print('Total del pedido: ${_total.value}');
      print('Items en el pedido: ${_items.length}');

      // Obtener el UID del usuario autenticado
      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = currentUser?.uid;

      // Obtener platillo, bebida y postre (uno de cada uno)
      Map<String, dynamic>? platillo;
      Map<String, dynamic>? bebida;
      Map<String, dynamic>? postre;
      String comentarios = '';
      double precio = 0.0;

      for (var item in _items) {
        if ((item['tipo'] ?? '').toLowerCase().contains('platillo')) {
          platillo = item;
        } else if ((item['tipo'] ?? '').toLowerCase().contains('bebida')) {
          bebida = item;
        } else if ((item['tipo'] ?? '').toLowerCase().contains('postre')) {
          postre = item;
        }
        if ((item['notas'] ?? '').toString().isNotEmpty) {
          comentarios = item['notas'];
        }
        precio += (item['precio'] ?? 0.0) * (item['cantidad'] ?? 1);
      }

      // Formatear fecha y hora
      final now = DateTime.now();
      final fecha = DateFormat('dd/MM/yyyy').format(now);
      final hora = DateFormat('hh:mm:ss a', 'es_MX').format(now);

      // Obtener el último ID_Orden
      int nuevoIdOrden = 1;
      final snapshot = await _firestore
          .collection('ordenes')
          .orderBy('ID_Orden', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty &&
          snapshot.docs.first.data().containsKey('ID_Orden')) {
        nuevoIdOrden = (snapshot.docs.first['ID_Orden'] as int) + 1;
      }

      Map<String, dynamic> orderData = {
        'Platillo': platillo != null ? platillo['nombre'] : null,
        'Bebidas': bebida != null ? bebida['nombre'] : null,
        'Postre': postre != null ? postre['nombre'] : null,
        'Cantidad': platillo != null
            ? platillo['cantidad']
            : bebida != null
                ? bebida['cantidad']
                : postre != null
                    ? postre['cantidad']
                    : 1,
        'Comentarios': comentarios,
        'Precio': precio,
        'Total': _total.value,
        'status': 'pending',
        'Fecha': fecha,
        'Hora': hora,
        'ID_Orden': nuevoIdOrden,
        'userId': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'items': _items
            .map((item) => {
                  'nombre': item['nombre'],
                  'cantidad': item['cantidad'],
                  'precio': item['precio'],
                })
            .toList(),
      };
      if (usuario['PK_ROL'] == 3) {
        orderData['PK_Estudiante'] = uid;
      } else if (usuario['PK_ROL'] == 4) {
        orderData['PK_Docente'] = uid;
      }

      await _firestore.collection('ordenes').add(orderData);

      clearCart();

      Get.snackbar(
        'Pedido realizado',
        '¡Gracias por tu compra! Tu pedido ha sido registrado.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: Duration(seconds: 3),
        icon: Icon(Icons.check_circle, color: Colors.green[800]),
      );
    } catch (e) {
      print('Error al guardar pedido: $e');
      Get.snackbar(
        'Error',
        'No se pudo procesar el pedido: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red[800]),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
