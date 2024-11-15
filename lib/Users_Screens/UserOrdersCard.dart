import 'package:flutter/material.dart';
import 'package:furniture_home/DB/Product.dart';

class UserOrdersCard extends StatelessWidget {
  final List<Product> orderedProducts;
  final List<int> productsQuantity;
  final int state;

  UserOrdersCard({
    required this.orderedProducts,
    required this.state,
    required this.productsQuantity,
  });

  @override
  Widget build(BuildContext context) {
    String orderStatus = '';
    Color orderStatusColor = Colors.black;

    // Determine the order status based on the state value
    switch (state) {
      case 0:
        orderStatus = 'Under Processing';
        orderStatusColor = const Color.fromRGBO(33, 150, 243, 1);
        break;
      case 1:
        orderStatus = 'Under Processing';
        orderStatusColor = const Color.fromRGBO(33, 150, 243, 1);
        break;
      case 2:
        orderStatus = 'Order Delivered';
        orderStatusColor = Colors.green;
        break;
      default:
        orderStatus = 'Unknown';
        break;
    }

    // Calculate the total price based on the quantity and price of each product
    double totalPrice = 0;
    for (int i = 0; i < orderedProducts.length; i++) {
      totalPrice += orderedProducts[i].price * productsQuantity[i];
    }

    return Container(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order Status: $orderStatus",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: orderStatusColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Ordered Products:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: List.generate(orderedProducts.length, (index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(orderedProducts[index].image),
                    ),
                    title: Text(
                        "${orderedProducts[index].description} x${productsQuantity[index]}"),
                    subtitle: Text(
                        "Price: \$${orderedProducts[index].price * productsQuantity[index]}"),
                  );
                }),
              ),
              SizedBox(height: 10),
              Text(
                "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
