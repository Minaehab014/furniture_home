import 'package:flutter/material.dart';
import 'package:furniture_home/DB/Order.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get getOrders => _orders;

//Get user orders------------------------------------------------
  List<Order> getuserorders(String uid) {
    List<Order> o = [];
    _orders.forEach((element) {
      if (element.userid == uid) {
        o.add(element);
      }
    });
    return o;
  }

// GetVendor orders-------------------------------------------------
  List<Order> getvendororders(String uid) {
    List<Order> o = [];
    _orders.forEach((element) {
      element.vendorsList.forEach((item) {
        if (item['userId'] == uid) {
          o.add(element);
          return;
        }
      });
    });
    return o;
  }

//vendor state--------------------------------------------------------------
  int getvendorstate(List<Map<String, dynamic>> VendorList, vid) {
    var i;
    VendorList.forEach((element) {
      if (element['userId'] == vid) {
        i = element['state'];
      }
    });
    return i;
  }

  //Buy items------------------------------------------------------

  Future<void> buyitems(List<Map<String, dynamic>> _userlist, String _userid,
      String _token) async {
    try {
      var cart = await http.get(Uri.parse(
          "https://furniture-ef43b-default-rtdb.firebaseio.com/Cart.json?auth=$_token"));
      var fetchedCart = json.decode(cart.body);
      var id;
      // delete all items in the cart od the user how ordered products
      fetchedCart.forEach((key, c) async {
        if (c['userid'] == _userid) {
          id = key;
          await http.delete(
            Uri.parse(
                "https://furniture-ef43b-default-rtdb.firebaseio.com/Cart/$id.json?auth=$_token"),
          );
        }
      });
      Set<String> vendorsid = Set<String>();

      for (var element in _userlist) {
        final productResponse = await http.get(Uri.parse(
            "https://furniture-ef43b-default-rtdb.firebaseio.com/Products/${element['pid']}.json?auth=$_token"));

        if (productResponse.statusCode == 200) {
          final fetchedProduct =
              json.decode(productResponse.body) as Map<String, dynamic>;
          final userId = fetchedProduct['userId'];
          vendorsid.add(userId);
          print("Added userId: $userId");
        } else {
          print(
              "Failed to fetch product for PID: ${element['pid']}. Status code: ${productResponse.statusCode}");
          // Handle the error accordingly
        }
      }

      List<String> uniqueVendorsid = vendorsid.toList();

      List<Map<String, dynamic>> vendorsList = uniqueVendorsid
          .map((userId) => {'userId': userId, 'state': 0})
          .toList();

      var order = await http.post(
          Uri.parse(
              "https://furniture-ef43b-default-rtdb.firebaseio.com/Orders.json?auth=$_token"),
          body: json.encode({
            "userid": _userid,
            "userlist": _userlist,
            "state": 0,
            "vendorsliststate": vendorsList
          }));

      _orders.add(Order(
          id: json.decode(order.body)['name'],
          productsid: _userlist,
          userid: _userid,
          state: 0,
          vendorsList: vendorsList));

      notifyListeners();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> fetchOrdersFromServer() async {
    final OrderUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Orders.json");

    try {
      var response = await http.get(OrderUrl);

      if (response.statusCode == 200) {
        var responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty response received from the server.');
          return; // Exit early if response is empty
        }

        var fetchedData = json.decode(responseBody);
        _orders.clear();
        // Iterate over each key-value pair in fetchedData
        fetchedData.forEach((orderId, orderData) {
          // Check if orderData is a map
          if (orderData is Map<String, dynamic>) {
            // Parse orderData and add to _orders list

            _orders.add(Order(
                id: orderId,
                userid: orderData['userid'],
                state: orderData['state'],
                productsid: (orderData['userlist'] as List<dynamic>)
                    .cast<Map<String, dynamic>>(),
                vendorsList: (orderData['vendorsliststate'] as List<dynamic>)
                    .cast<Map<String, dynamic>>()));
          } else {
            print('Invalid order format for order with ID: $orderId');
          }
        });

        notifyListeners();
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (err) {
      print('Error fetching data: $err');
    }
  }

//update vendor state----------------------------------------------------------

  Future<void> updatevendorstate(
      String _Orderid, String vid, String _token) async {
    final OrderUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Orders/$_Orderid.json?auth=$_token");
    try {
      var res = await http.get(OrderUrl);
      var fetchedres = json.decode(res.body);

      var newstate;

      //update state of this vendor
      for (int i = 0; i < fetchedres['vendorsliststate'].length; i++) {
        var item = fetchedres['vendorsliststate'][i];
        if (item['userId'] == vid) {
          newstate = item['state'] + 1;
          fetchedres['vendorsliststate'][i]['state'] = newstate;

          break;
        }
      }

      var r = await http.patch(OrderUrl,
          body: json
              .encode({"vendorsliststate": fetchedres['vendorsliststate']}));
      print(r.statusCode);

      var new_res = await http.get(OrderUrl);
      var new_fetchedres = json.decode(new_res.body);
      bool all_equal = true;

      new_fetchedres['vendorsliststate'].forEach((item) {
        if (item['state'] != newstate) {
          all_equal = false;
        }
      });

      if (all_equal)
        await http.patch(OrderUrl, body: json.encode({"state": newstate}));
      notifyListeners();
    } catch (err) {
      print(err.toString());
    }
  }
}
