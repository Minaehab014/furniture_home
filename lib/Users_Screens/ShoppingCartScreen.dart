import 'package:flutter/material.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/Providers/CartProvider.dart';
import 'package:furniture_home/Providers/OrderProvider.dart';
import 'package:furniture_home/Providers/ProductsProvider.dart';
import 'package:furniture_home/Users_Screens/CartCard.dart';
import 'package:provider/provider.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  bool _payWithCash = false;

  @override
  void initState() {
    super.initState();

    // Fetch data from the ProductsProvider
    Future.delayed(Duration.zero, () {
      Provider.of<CartProvider>(context, listen: false).fetchcart();
    });
  }

  @override
  Widget build(BuildContext context) {
    var cartprovider = Provider.of<CartProvider>(context, listen: true);
    var productprovider = Provider.of<ProductsProvider>(context, listen: true);
    var authprovider = Provider.of<AuthProvider>(context, listen: true);
    var orederprovider = Provider.of<OrderProvider>(context, listen: true);
    List<Map<String, dynamic>> userlist =
        cartprovider.getuserproductandquantity(authprovider.UserId);

    return RefreshIndicator(
      onRefresh: () async {
        await cartprovider.fetchcart();
        await productprovider.fetchProductsFromServer();
      },
      child: Column(
        children: [
          Expanded(
            child: userlist.isEmpty
                ? Center(child: Text("Empty"))
                : ListView.builder(
                    itemCount: userlist.length,
                    itemBuilder: (context, index) {
                      var item = userlist[index];
                      var productId = item['pid'];
                      int quantity = item['quantity'];

                      return CartCard(
                        product: productprovider.getProduct(productId)!,
                        quantity: quantity,
                      );
                    },
                  ),
          ),
          if (userlist.isNotEmpty)
            Column(
              children: [
                ListTile(
                  title: Text(
                    'Total Price: \$${calculateTotalPrice(userlist, productprovider)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                CheckboxListTile(
                  title: Text('Pay with cash'),
                  value: _payWithCash,
                  onChanged: (bool? value) {
                    setState(() {
                      _payWithCash = value ?? false;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_payWithCash) {
                      await orederprovider.buyitems(
                          userlist, authprovider.UserId, authprovider.token);
                      await cartprovider
                          .getuserproductandquantity(authprovider.UserId);
                      await cartprovider.fetchcart();
                      await productprovider.fetchProductsFromServer();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Please check "Pay with cash" to proceed.'),
                        ),
                      );
                    }
                  },
                  child: Text('Buy Items'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  double calculateTotalPrice(
      List<Map<String, dynamic>> userlist, ProductsProvider productprovider) {
    double totalPrice = 0;
    for (var item in userlist) {
      var productId = item['pid'];
      int quantity = item['quantity'];
      var product = productprovider.getProduct(productId);
      if (product != null) {
        totalPrice += product.price * quantity;
      }
    }
    return totalPrice;
  }
}
