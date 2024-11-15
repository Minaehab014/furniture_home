import "package:furniture_home/Vendor_screens/ManageOrderScreen.dart";
import "package:furniture_home/Vendor_screens/VendorAddScreen.dart";

import "package:furniture_home/Vendor_screens/VendorProfileScreen.dart";
import 'package:flutter/material.dart';

class TabsControllerScreen extends StatefulWidget {
  @override
  _TabsControllerScreenState createState() => _TabsControllerScreenState();
}

class _TabsControllerScreenState extends State<TabsControllerScreen> {
  final List<Widget> myPages = [
    VendorAddScreen(), // Add Product page
    VendorProfileScreen(),
    ManageOrderScreen()
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'View Orders',
          )
        ],
        currentIndex: selectedTabIndex,
        onTap: switchPage,
      ),
    );
  }
}
