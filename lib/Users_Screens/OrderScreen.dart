import 'package:flutter/material.dart';
import 'package:furniture_home/DB/Order.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/Providers/OrderProvider.dart';
import 'package:furniture_home/Providers/ProductsProvider.dart';
import 'package:furniture_home/Users_Screens/UserOrdersCard.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  void initState() {
    super.initState();

    // Fetch data from the ProductsProvider
    Future.delayed(Duration.zero, () {
      Provider.of<OrderProvider>(context, listen: false)
          .fetchOrdersFromServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: true);
    var orderprovider = Provider.of<OrderProvider>(context, listen: true);
    var productprovider = Provider.of<ProductsProvider>(context, listen: true);

    List<Order> Orders = orderprovider.getuserorders(authprovider.UserId);
    // print(authprovider.UserId);
    // print(Orders);
    return Orders.isEmpty
        ? Text("No Orders")
        : ListView.builder(
            itemCount: Orders.length,
            itemBuilder: (context, index) {
              return UserOrdersCard(
                orderedProducts:
                    productprovider.getproductlist(Orders[index].productsid),
                state: Orders[index].state,
                productsQuantity:
                    productprovider.getratelist(Orders[index].productsid),
              );
            },
          );
  }
}
