import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../pages/cart_page.dart';

class CartButton extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const CartButton({
    Key? key,
    this.userData,
  }) : super(key: key);

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
                icon: Icon(Icons.shopping_cart_outlined,
                    color: Colors.orange[800]),
                duration: Duration(seconds: 2),
              );
            } else {
              Get.to(() => CartPage(), arguments: userData);
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
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
