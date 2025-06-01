import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/services/cart_service.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();
  var cartItems = <ProductModel>[].obs;
  var isLoading = false.obs;
  var totalPrice = 0.0.obs;

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.cantidad);

  @override
  void onInit() {
    super.onInit();
    ever(cartItems, (_) => _calculateTotal());
  }

  void addItem(ProductModel item) {
    try {
      final existingItemIndex = cartItems.indexWhere((element) =>
          element.id == item.id && element.categoria == item.categoria);

      if (existingItemIndex != -1) {
        final existingItem = cartItems[existingItemIndex];
        cartItems[existingItemIndex] =
            existingItem.copyWith(cantidad: existingItem.cantidad + 1);
      } else {
        cartItems.add(item);
      }

      Get.snackbar(
        'Agregado al carrito',
        '${item.nombre} ha sido agregado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo agregar el item: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void removeItem(ProductModel item) {
    try {
      cartItems.remove(item);
      Get.snackbar(
        'Eliminado',
        '${item.nombre} fue removido del carrito',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo remover el item: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void updateQuantity(int index, int quantity) {
    try {
      if (quantity <= 0) {
        removeItem(cartItems[index]);
      } else {
        final item = cartItems[index];
        cartItems[index] = item.copyWith(cantidad: quantity);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la cantidad: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void updateNotes(int index, String notes) {
    try {
      final item = cartItems[index];
      cartItems[index] = item.copyWith(notas: notes);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron actualizar las notas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void clearCart() {
    cartItems.clear();
    totalPrice.value = 0.0;
  }

  void _calculateTotal() {
    totalPrice.value =
        cartItems.fold(0.0, (sum, item) => sum + (item.precio * item.cantidad));
  }

  Future<void> saveOrder(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      await _cartService.saveOrder(cartItems, userData);
      clearCart();
      Get.snackbar(
        'Éxito',
        'Pedido registrado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo registrar el pedido: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }
}
