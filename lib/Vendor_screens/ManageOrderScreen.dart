import 'package:flutter/material.dart';
import 'package:furniture_home/DB/Order.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/Providers/OrderProvider.dart';
import 'package:furniture_home/Providers/ProductsProvider.dart';
import 'package:furniture_home/Vendor_screens/ManageOrderCard.dart';
import 'package:provider/provider.dart';

class ManageOrderScreen extends StatefulWidget {
  const ManageOrderScreen({Key? key}) : super(key: key);

  @override
  _ManageOrderScreenState createState() => _ManageOrderScreenState();
}

class _ManageOrderScreenState extends State<ManageOrderScreen> {
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

    List<Order> Orders = orderprovider.getvendororders(authprovider.UserId);
    // print(authprovider.UserId);
    print(Orders);

    return Orders.isEmpty
        ? Text("No Orders")
        : ListView.builder(
            itemCount: Orders.length,
            itemBuilder: (context, index) {
              return ManageOrderCard(
                orderedProducts: productprovider.getVendorProductList(
                    Orders[index].productsid, authprovider.UserId),
                state: orderprovider.getvendorstate(
                    Orders[index].vendorsList, authprovider.UserId),
                productsQuantity:
                    productprovider.getratelist(Orders[index].productsid),
                orderid: Orders[index].id,
              );
            },
          );
  }
}
