import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Consulta temporal sin ordenamiento mientras se crea el índice
      final QuerySnapshot querySnapshot = await _firestore
          .collection('ordenes')
          .where('userId', isEqualTo: userId)
          .get();

      // Ordenar los resultados en memoria
      final sortedDocs = querySnapshot.docs.toList()
        ..sort((a, b) {
          final aTimestamp = a['timestamp'] as Timestamp?;
          final bTimestamp = b['timestamp'] as Timestamp?;
          if (aTimestamp == null || bTimestamp == null) return 0;
          return bTimestamp.compareTo(aTimestamp);
        });

      orders.value = sortedDocs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      Get.snackbar(
        'Error',
        'No se pudieron cargar los pedidos',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      // Primero verificar si el pedido existe y su estado actual
      final orderDoc =
          await _firestore.collection('ordenes').doc(orderId).get();

      if (!orderDoc.exists) {
        Get.snackbar(
          'Error',
          'El pedido no existe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
        return;
      }

      final currentStatus = orderDoc.data()?['status'] as String?;

      if (currentStatus == 'ready' || currentStatus == 'completed') {
        Get.snackbar(
          'Error',
          'No se puede cancelar un pedido que ya está listo o completado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
        return;
      }

      if (currentStatus == 'cancelled') {
        Get.snackbar(
          'Error',
          'Este pedido ya fue cancelado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
        return;
      }

      await _firestore.collection('ordenes').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      await fetchOrders(); // Actualizar la lista

      Get.snackbar(
        'Éxito',
        'Pedido cancelado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green[800]),
      );
    } catch (e) {
      print('Error cancelling order: $e');
      Get.snackbar(
        'Error',
        'No se pudo cancelar el pedido: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red[800]),
      );
    }
  }

  Future<void> clearHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['completed', 'cancelled']).get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      await fetchOrders(); // Actualizar la lista

      Get.snackbar(
        'Éxito',
        'Historial limpiado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error clearing history: $e');
      Get.snackbar(
        'Error',
        'No se pudo limpiar el historial',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
