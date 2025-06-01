import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../vistas/cart_page.dart';

class CartIcon extends StatelessWidget {
  const CartIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () {
            final cartController = Get.find<CartController>();
            if (cartController.cartItems.isEmpty) {
              Get.snackbar(
                'Carrito vacío',
                'Añade algunos platillos a tu carrito',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange[100],
                colorText: Colors.orange[800],
              );
            } else {
              Get.to(() => CartPage());
            }
          },
        ),
        GetX<CartController>(
          builder: (controller) {
            if (controller.itemCount > 0) {
              return Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${controller.itemCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
