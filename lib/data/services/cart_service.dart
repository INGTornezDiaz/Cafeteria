import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveOrder(
      List<ProductModel> items, Map<String, dynamic> userData) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Usuario no autenticado');

      final orderData = {
        'fecha': DateTime.now().toIso8601String(),
        'usuario': {
          'id': currentUser.uid,
          'nombre': userData['nombre'],
          'rol': userData['rol'],
        },
        'items': items.map((item) => item.toMap()).toList(),
        'total':
            items.fold(0.0, (sum, item) => sum + (item.precio * item.cantidad)),
        'estado': 'pendiente',
        'comentarios': '',
      };

      await _firestore.collection('ordenes').add(orderData);
    } catch (e) {
      throw Exception('Error al guardar la orden: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('ordenes')
          .where('usuario.id', isEqualTo: userId)
          .orderBy('fecha', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error al obtener historial de órdenes: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('ordenes')
          .doc(orderId)
          .update({'estado': newStatus});
    } catch (e) {
      throw Exception('Error al actualizar estado de la orden: $e');
    }
  }
}
