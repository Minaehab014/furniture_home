import 'package:flutter/material.dart';
import 'package:furniture_home/DB/Cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartProvider with ChangeNotifier {
  List<Cart> _cart = [];

  List<Cart> get getCart => _cart;

//get user products list and quantity
  List<Map<String, dynamic>> getuserproductandquantity(String userid) {
    List<Map<String, dynamic>> userlist = [];
    _cart.forEach((element) {
      if (element.userid == userid) {
        userlist.add({"pid": element.productid, "quantity": element.quantity});
      }
    });
    return userlist;
  }

  //Add products to Cart--------------------------------------------------------
  Future<void> addtocart(String _vednorid, String _userid, String _productid,
      String _token, int _quantity, context, bool auth) async {
    final uri = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Cart.json?auth=$_token");
    final productUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Products/$_productid.json?auth=$_token");

    try {
      if (!auth) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/LogIn');
      } else {
        if (_quantity != 0) {
          bool found = false;
          var response = await http.get(uri);
          var fetcheddata = json.decode(response.body);
          var id;
          int q = 0;
          if (fetcheddata == null) {
            await http.post(uri,
                body: json.encode({
                  "userid": _userid,
                  "vendorid": _vednorid,
                  "productid": _productid,
                  "quantity": 1
                }));
          } else {
            fetcheddata.forEach((key, c) async {
              if (c['userid'] == _userid && c['productid'] == _productid) {
                found = true;
                id = key;
                q = c['quantity'] + 1;
              }
            });
            if (found) {
              await http.patch(
                  Uri.parse(
                      "https://furniture-ef43b-default-rtdb.firebaseio.com/Cart/$id.json?auth=$_token"),
                  body: json.encode({"quantity": q}));
            } else {
              await http.post(uri,
                  body: json.encode({
                    "userid": _userid,
                    "vendorid": _vednorid,
                    "productid": _productid,
                    "quantity": 1
                  }));
            }
          }
          await http.patch(productUrl,
              body: json.encode({"quantity": _quantity - 1}));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added To Shopping Bag'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No Avalible Quantity'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      notifyListeners();
    } catch (err) {
      print(err.toString());
    }
  }

  //fetch all items in cart-----------------------------------------------------
  Future<void> fetchcart() async {
    final uri = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Cart.json");

    try {
      var response = await http.get(uri);
      var fetchedresponse = json.decode(response.body);
      _cart.clear();
      fetchedresponse.forEach((key, item) {
        _cart.add(Cart(
            id: key,
            userid: item['userid'],
            vendorid: item['vendorid'],
            productid: item['productid'],
            quantity: item['quantity']));
      });
      notifyListeners();
    } catch (err) {
      print(err.toString());
    }
  }

//remove products from cart

  Future<void> removefromcart(
      String _vednorid,
      String _userid,
      String _productid,
      String _token,
      int _cartquantity,
      int _productquatity,
      context,
      bool auth) async {
    final uri = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Cart.json?auth=$_token");
    final productUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Products/$_productid.json?auth=$_token");

    try {
      if (!auth) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/LogIn');
      } else {
        var id;
        var cartresponse = await http.get(uri);
        var cartfetcheddata = json.decode(cartresponse.body);
        if (_cartquantity == 1) {
          //remove from cart

          cartfetcheddata.forEach((key, element) {
            if (element["userid"] == _userid &&
                element['productid'] == _productid) {
              id = key;
            }
          });

          await http.delete(Uri.parse(
              "https://furniture-ef43b-default-rtdb.firebaseio.com/Cart/$id.json?auth=$_token"));
          await http.patch(productUrl,
              body: json.encode({"quantity": _productquatity + 1}));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your Product is removed from cart'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          cartfetcheddata.forEach((key, element) {
            if (element["userid"] == _userid &&
                element['productid'] == _productid) {
              id = key;
            }
          });
          await http.patch(
              Uri.parse(
                  "https://furniture-ef43b-default-rtdb.firebaseio.com/Cart/$id.json?auth=$_token"),
              body: json.encode({"quantity": _cartquantity - 1}));
          await http.patch(productUrl,
              body: json.encode({"quantity": _productquatity + 1}));
        }
      }
      notifyListeners();
    } catch (err) {
      print(err.toString());
    }
  }
}
