import 'package:flutter/material.dart';
import 'package:furniture_home/Users_Screens/OrderScreen.dart';
import 'package:furniture_home/Users_Screens/UserProfileScreen.dart';
import 'package:furniture_home/Users_Screens/UsersHomePage.dart';
import 'package:furniture_home/Users_Screens/ShoppingCartScreen.dart';

class UsersTabsController extends StatefulWidget {
  @override
  _UsersTabsControllerState createState() => _UsersTabsControllerState();
}

class _UsersTabsControllerState extends State<UsersTabsController> {
  final List<Widget> myPages = [
    UsersHomePage(),
    ShoppingCartScreen(),
    OrderScreen(),
    UserProfileScreen()
  ];
  var selectedTabIndex = 0;

  void switchPage(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Furniture Hub'),
        backgroundColor: Colors.blue,
      ),
      body: myPages[selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shopping Bag',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedTabIndex,
        onTap: switchPage,
      ),
    );
  }
}
