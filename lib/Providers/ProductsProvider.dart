import 'package:flutter/material.dart';
import 'package:furniture_home/DB/Product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredproducts = [];

// getters----------------------------------------------------------

  List<Product> get getAllProducts =>
      _products.where((product) => product.quantity > 0).toList();
  List<Product> get getFilteredProducts =>
      _filteredproducts.where((product) => product.quantity > 0).toList();

//Get Specific Product---------------------------------------------

  Product? getProduct(String pid) {
    Product? p;
    _products.forEach((element) {
      if (element.id == pid) {
        p = element;
      }
    });
    return p;
  }

// products list-------------------------------------------------------------
  List<Product> getproductlist(List<Map<String, dynamic>> userlist) {
    List<Product> list = [];
    var p;
    userlist.forEach((element) {
      p = getProduct(element['pid']);
      if (p != null) {
        list.add(p);
      }
    });
    return list;
  }

//Get VendorProductList
  List<Product> getVendorProductList(
    List<Map<String, dynamic>> userlist,
    String _vendorid,
  ) {
    List<Product> list = [];
    print("mina");
    userlist.forEach((element) {
      Product? product = getProduct(element['pid']);
      if (product != null && product.userId == _vendorid) {
        // Add the product to the list
        list.add(product);
      }
    });
    return list;
  }

// rate list------------------------------------------------------------------
  List<int> getratelist(List<Map<String, dynamic>> userlist) {
    List<int> list = [];
    int i;
    userlist.forEach((element) {
      i = element['quantity'];
      list.add(i);
    });
    return list;
  }

// Get Product Rating----------------------------------------------
  int getrating(String userid, String pid) {
    int userrate = 0;
    _products.forEach((element) {
      if (element.id == pid) {
        element.rating.forEach((rateing) {
          if (rateing['uid'] == userid) {
            userrate = rateing['rate'];
          }
        });
      }
    });
    return userrate;
  }

//Get average Rating------------------------------------------
  double getaverage(String pid) {
    double averagerating = 0;
    int count = -1;
    _products.forEach((element) {
      if (element.id == pid) {
        element.rating.forEach((rateing) {
          averagerating = averagerating + rateing['rate'];
          count += 1;
        });
      }
    });
    if (averagerating == 0) {
      return 0;
    } else {
      return averagerating / count;
    }
  }

// get product comments---------------------------------------------------
  List<Map<String, dynamic>> getcomments(String pid) {
    List<Map<String, dynamic>> cmnts = [];

    _products.forEach((product) {
      if (product.id == pid) {
        product.comments.forEach((c) {
          cmnts.add(c);
        });
      }
    });
    return cmnts;
  }

//Add new products-----------------------------------------------------------------
  Future<void> addProduct(
      String uid,
      int _quantity,
      String _imageUrl,
      double _price,
      String _description,
      String _category,
      String _subCategory,
      String _token,
      double _sum_rating,
      double _count_ratings) async {
    final uri = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Products.json?auth=$_token");

    try {
      final response = await http.post(
        uri,
        body: json.encode({
          'userId': uid,
          'quantity': _quantity,
          'price': _price,
          'description': _description,
          'category': _category,
          'subCategory': _subCategory,
          'image': _imageUrl,
          "sum_rating": _sum_rating,
          "count_ratings": _count_ratings,
          "rating": [
            {"uid": "", "rate": 0}
          ],
          "comments": [
            {"uid": '', "comment": 'Comments'}
          ]
        }),
      );

      if (response.statusCode == 200) {
        _products.add(Product(
            id: json.decode(response.body)['name'],
            price: _price,
            description: _description,
            quantity: _quantity,
            category: _category,
            subCategory: _subCategory,
            userId: uid,
            image: _imageUrl,
            sum_rating: _sum_rating,
            cout_ratings: _count_ratings,
            rating: [
              {"uid": "", "rate": -1}
            ],
            comments: [
              {"uid": '', "comment": 'Comments'}
            ]));

        notifyListeners();
      } else {
        // Handle unexpected status code
        print(response.statusCode);
      }
    } catch (error) {
      // Handle any errors that occur during the HTTP request
      print('Error adding product: $error');
    }
  }

// fETCH all products from server---------------------------------------------------------
  Future<void> fetchProductsFromServer() async {
    final productUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Products.json");

    try {
      var response = await http.get(productUrl);
      // print(response.body);

      var fetchedData = json.decode(response.body) as Map<String, dynamic>;
      _products.clear();
      fetchedData.forEach((key, value) {
        _products.add(Product(
            id: key,
            price: value['price'],
            description: value['description'],
            quantity: value['quantity'],
            category: value['category'],
            subCategory: value['subCategory'],
            userId: value['userId'],
            image: value['image'],
            sum_rating: value['sum_rating'],
            cout_ratings: value['count_ratings'],
            rating: (value['rating'] ?? []).cast<Map<String, dynamic>>(),
            comments: (value['comments'] ?? []).cast<Map<String, dynamic>>()));
      });

      notifyListeners();
    } catch (err) {
      print(err.toString());
      print('Error fetching data: $err');
    }
  }

// ADD AND UPDATE RATEINGS------------------------------------------------------------------------------
  Future<void> addandupdaterating(String token, String userid, String productid,
      int Rate, bool authanticated, context) async {
    final productUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Products/$productid.json?auth=$token");

    try {
      if (!authanticated) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/');
        Navigator.of(context).pushNamed('/LogIn');
      } else {
        var response = await http.get(productUrl);
        // print(response.body);
        var fetchedproduct = json.decode(response.body);
        bool found = false;

        if (fetchedproduct['rating'].length == 1) {
          fetchedproduct['rating'].add({"uid": userid, "rate": Rate});
          var response_update = await http.patch(productUrl,
              body: jsonEncode({'rating': fetchedproduct['rating']}));
          print(response_update.body);
        } else {
          fetchedproduct['rating'].forEach((item) {
            if (userid == item['uid']) {
              item['rate'] = Rate;
              found = true;
            }
          });
          if (!found) {
            fetchedproduct['rating'].add({"uid": userid, "rate": Rate});
            await http.patch(productUrl,
                body: jsonEncode({'rating': fetchedproduct['rating']}));
          }
          await http.patch(productUrl,
              body: jsonEncode({'rating': fetchedproduct['rating']}));
        }
        notifyListeners();
      }
    } catch (err) {
      print("error on ratin + $err");
    }
  }

//Add comments-----------------------------------------

  Future<void> addcomment(String token, String userid, String productid,
      String comm, bool authanticated, context) async {
    final productUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Products/$productid.json?auth=$token");
    final usertUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Users.json?auth=$token");

    try {
      if (!authanticated) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/LogIn');
      } else {
        var response = await http.get(productUrl);
        var users_response = await http.get(usertUrl);
        // print(response.body);
        var fetchedproduct = json.decode(response.body);
        var fetchedusers = json.decode(users_response.body);
        var user;
        fetchedusers.forEach((key, value) {
          // Access the 'id' field within each user node
          if (value["id"] == userid) {
            user = value;
          }
        });

        // if (fetchedproduct['comments'].length == 1) {
        //   fetchedproduct['comments'] = [];
        //   fetchedproduct['comments'].add({"uid": userid, "comment": comm});
        //   await http.patch(productUrl,
        //       body: jsonEncode({'comments': fetchedproduct['comments']}));
        // } else {
        fetchedproduct['comments']
            .add({"uid": user['username'], "comment": comm});
        await http.patch(productUrl,
            body: jsonEncode({'comments': fetchedproduct['comments']}));
        // }
        notifyListeners();
      }
    } catch (err) {
      print("error on here + $err");
    }
  }

// Filter by Categories--------------------------------------------------

  Future<void> filterproducts(String category) async {
    final productUrl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Products.json");

    try {
      print("Mina");
      var response = await http.get(productUrl);
      _filteredproducts.clear();
      var filtered = json.decode(response.body) as Map<String, dynamic>;

      if (category == 'Living Room') {
        filtered.forEach((key, value) {
          if (value['category'] == category) {
            _filteredproducts.add(Product(
                id: key,
                price: value['price'],
                description: value['description'],
                quantity: value['quantity'],
                category: value['category'],
                subCategory: value['subCategory'],
                userId: value['userId'],
                image: value['image'],
                sum_rating: value['sum_rating'],
                cout_ratings: value['count_ratings'],
                rating: (value['rating'] ?? []).cast<Map<String, dynamic>>(),
                comments:
                    (value['comments'] ?? []).cast<Map<String, dynamic>>()));
          }
        });
      }
      if (category == 'Kitchen') {
        filtered.forEach((key, value) {
          if (value['category'] == category) {
            _filteredproducts.add(Product(
                id: key,
                price: value['price'],
                description: value['description'],
                quantity: value['quantity'],
                category: value['category'],
                subCategory: value['subCategory'],
                userId: value['userId'],
                image: value['image'],
                sum_rating: value['sum_rating'],
                cout_ratings: value['count_ratings'],
                rating: (value['rating'] ?? []).cast<Map<String, dynamic>>(),
                comments:
                    (value['comments'] ?? []).cast<Map<String, dynamic>>()));
          }
        });
      }
      if (category == 'Bedroom') {
        filtered.forEach((key, value) {
          if (value['category'] == category) {
            _filteredproducts.add(Product(
                id: key,
                price: value['price'],
                description: value['description'],
                quantity: value['quantity'],
                category: value['category'],
                subCategory: value['subCategory'],
                userId: value['userId'],
                image: value['image'],
                sum_rating: value['sum_rating'],
                cout_ratings: value['count_ratings'],
                rating: (value['rating'] ?? []).cast<Map<String, dynamic>>(),
                comments:
                    (value['comments'] ?? []).cast<Map<String, dynamic>>()));
          }
        });
      }
      if (category == 'Furniture') {
        filtered.forEach((key, value) {
          if (value['subCategory'] == category) {
            _filteredproducts.add(Product(
                id: key,
                price: value['price'],
                description: value['description'],
                quantity: value['quantity'],
                category: value['category'],
                subCategory: value['subCategory'],
                userId: value['userId'],
                image: value['image'],
                sum_rating: value['sum_rating'],
                cout_ratings: value['count_ratings'],
                rating: (value['rating'] ?? []).cast<Map<String, dynamic>>(),
                comments:
                    (value['comments'] ?? []).cast<Map<String, dynamic>>()));
          }
        });
      }
      if (category == 'Decorations') {
        filtered.forEach((key, value) {
          if (value['subCategory'] == category) {
            _filteredproducts.add(Product(
                id: key,
                price: value['price'],
                description: value['description'],
                quantity: value['quantity'],
                category: value['category'],
                subCategory: value['subCategory'],
                userId: value['userId'],
                image: value['image'],
                sum_rating: value['sum_rating'],
                cout_ratings: value['count_ratings'],
                rating: (value['rating'] ?? []).cast<Map<String, dynamic>>(),
                comments:
                    (value['comments'] ?? []).cast<Map<String, dynamic>>()));
          }
        });
      }

      notifyListeners();
    } catch (err) {
      print(err.toString());
      print('Error fetching data: $err');
    }
  }
}
