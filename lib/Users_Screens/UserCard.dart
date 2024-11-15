import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:furniture_home/DB/Product.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/Providers/CartProvider.dart';
import 'package:furniture_home/Providers/ProductsProvider.dart';
import 'package:provider/provider.dart';

class UserCard extends StatefulWidget {
  final Product product;

  UserCard({required this.product});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
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
                    width: 10,
                    height: 10,
                  ),
                ],
              ),
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: autprovider.isAuthanticated
                        ? productprovider
                            .getrating(autprovider.UserId, widget.product.id)
                            .toDouble()
                        : 0.0,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) async {
                      autprovider.isAuthanticated
                          ? await productprovider
                              .getrating(autprovider.UserId, widget.product.id)
                              .toDouble()
                          : rating = 0;
                      avg;
                      await productprovider.getrating(
                          autprovider.UserId, widget.product.id);
                      await productprovider.addandupdaterating(
                          autprovider.token,
                          autprovider.UserId,
                          widget.product.id,
                          rating.toInt(),
                          autprovider.isAuthanticated,
                          context);
                      await productprovider.fetchProductsFromServer();
                    },
                    itemSize: 20,
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
                        await productprovider.fetchProductsFromServer();
                        await cartprovider.fetchcart();
                      },
                      icon: Icon(Icons.shopping_cart)),
                  SizedBox(
                    width: 130,
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 400,
                            color: Colors.white,
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _comm,
                                        decoration: InputDecoration(
                                          hintText: 'Write a comment...',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () async {
                                        await productprovider.addcomment(
                                            autprovider.token,
                                            autprovider.UserId,
                                            widget.product.id,
                                            _comm.text,
                                            autprovider.isAuthanticated,
                                            context);
                                        _comm.clear();
                                        await productprovider
                                            .fetchProductsFromServer();
                                      },
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: ListView(
                                    children: productprovider
                                        .getcomments(widget.product.id)
                                        .map(
                                          (e) => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 8),
                                              Text(
                                                e['uid'],
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              Text(
                                                e['comment'],
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text('Comments'),
                  ),
                ],
              ),
              SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}
