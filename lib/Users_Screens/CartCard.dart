import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:furniture_home/DB/Product.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/Providers/CartProvider.dart';
import 'package:furniture_home/Providers/ProductsProvider.dart';
import 'package:provider/provider.dart';

class CartCard extends StatefulWidget {
  final Product product;
  final int quantity;

  CartCard({required this.product, required this.quantity});

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  TextEditingController _comm = TextEditingController();

  void dispose() {
    _comm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var productprovider = Provider.of<ProductsProvider>(context, listen: true);
    var autprovider = Provider.of<AuthProvider>(context, listen: true);
    var cartprovider = Provider.of<CartProvider>(context, listen: true);
    double avg = productprovider.getaverage(widget.product.id).toDouble();
    return Container(
      width: double.infinity, // Expand to fill available width
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      widget.product.image,
                      fit: BoxFit.scaleDown,
                      height: 200,
                      width: double.infinity,
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Description: ${widget.product.description}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blueAccent,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: Colors.green,
                  ), // Icon widget
                  SizedBox(), // Adjust the spacing between icon and text
                  Text(
                    "${widget.product.price}",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(width: 10),

                  Icon(
                    Icons.star_half,
                    color: Colors.amber,
                  ),
                  Text(
                    "AVG: ${avg}",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Oredrd Quantity: ${widget.quantity}"),
                  SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      onPressed: () async {
                        await cartprovider.addtocart(
                            widget.product.userId,
                            autprovider.UserId,
                            widget.product.id,
                            autprovider.token,
                            widget.product.quantity,
                            context,
                            autprovider.isAuthanticated);
                        await cartprovider.fetchcart();
                        await productprovider.fetchProductsFromServer();
                      },
                      icon: Icon(Icons.add)),
                  IconButton(
                      onPressed: () async {
                        await cartprovider.removefromcart(
                            widget.product.userId,
                            autprovider.UserId,
                            widget.product.id,
                            autprovider.token,
                            widget.quantity,
                            widget.product.quantity,
                            context,
                            autprovider.isAuthanticated);
                        await cartprovider.fetchcart();
                        await productprovider.fetchProductsFromServer();
                      },
                      icon: Icon(Icons.remove))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
