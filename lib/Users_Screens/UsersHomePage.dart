import 'package:flutter/material.dart';
import 'package:furniture_home/Providers/ProductsProvider.dart';
import 'package:furniture_home/Users_Screens/UserCard.dart';
import 'package:provider/provider.dart';

class UsersHomePage extends StatefulWidget {
  const UsersHomePage({Key? key}) : super(key: key);

  @override
  _UsersHomePageState createState() => _UsersHomePageState();
}

class _UsersHomePageState extends State<UsersHomePage> {
  String selected_cat = "All"; // Track selected category separately

  @override
  void initState() {
    super.initState();

    // Fetch data from the ProductsProvider
    Future.delayed(Duration.zero, () {
      Provider.of<ProductsProvider>(context, listen: false)
          .fetchProductsFromServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    var productsProvider = Provider.of<ProductsProvider>(context);
    var products = productsProvider.getAllProducts;
    if (selected_cat == "All") {
      products = productsProvider.getAllProducts;
    } else {
      products = productsProvider.getFilteredProducts;
    }
    List<String> cat = [
      "All",
      "Living Room",
      "Kitchen",
      "Bedroom",
      "Furniture",
      "Decorations"
    ];

    return RefreshIndicator(
      onRefresh: () async {
        await productsProvider.fetchProductsFromServer();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selected_cat,
                underline: Container(
                  height: 2,
                  color: Theme.of(context)
                      .primaryColor, // Customize underline color
                ),
                icon: Icon(Icons.arrow_drop_down), // Customize dropdown icon
                elevation: 8,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .color), // Customize text color
                onChanged: (String? newValue) {
                  setState(() {
                    selected_cat = newValue!;
                  });

                  if (selected_cat != "All") {
                    productsProvider.filterproducts(selected_cat);
                  } else {
                    productsProvider.fetchProductsFromServer();
                  }
                },
                items: cat.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return products.length == 0
                    ? Text("Empty")
                    : UserCard(
                        product: products[index],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
