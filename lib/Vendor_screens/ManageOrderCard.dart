import 'package:flutter/material.dart';
import 'package:furniture_home/DB/Product.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/Providers/OrderProvider.dart';
import 'package:provider/provider.dart';

class ManageOrderCard extends StatefulWidget {
  final List<Product> orderedProducts;
  final List<int> productsQuantity;
  final int state;
  final String orderid;

  ManageOrderCard({
    required this.orderedProducts,
    required this.state,
    required this.productsQuantity,
    required this.orderid,
  });

  @override
  State<ManageOrderCard> createState() => _ManageOrderCardState();
}

class _ManageOrderCardState extends State<ManageOrderCard> {
  @override
  Widget build(BuildContext context) {
    var orderprovider = Provider.of<OrderProvider>(context, listen: true);
    var authprovider = Provider.of<AuthProvider>(context, listen: true);
    String orderStatus = '';
    Color orderStatusColor = Colors.black;

    // Determine the order status based on the state value
    switch (widget.state) {
      case 0:
        orderStatus = 'Order Sent';
        orderStatusColor = Colors.blue;
        break;
      case 1:
        orderStatus = 'Order Shipped';
        orderStatusColor = Colors.orange;
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
    for (int i = 0; i < widget.orderedProducts.length; i++) {
      totalPrice +=
          widget.orderedProducts[i].price * widget.productsQuantity[i];
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
                children: List.generate(widget.orderedProducts.length, (index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(widget.orderedProducts[index].image),
                    ),
                    title: Text(
                        "${widget.orderedProducts[index].description} x${widget.productsQuantity[index]}"),
                    subtitle: Text(
                        "Price: \$${widget.orderedProducts[index].price * widget.productsQuantity[index]}"),
                  );
                }),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  widget.state != 2
                      ? ElevatedButton(
                          onPressed: () async {
                            await orderprovider.updatevendorstate(
                                widget.orderid,
                                authprovider.UserId,
                                authprovider.token);
                            await orderprovider.fetchOrdersFromServer();
                          },
                          child: Text("Update"))
                      : Text("")
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
