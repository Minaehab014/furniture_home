import 'package:flutter/material.dart';
import 'package:furniture_home/DB/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  List<User> user = [];

//get type-----------------------------------------------------------------
  int getusertype(String uid) {
    int t = -1;
    user.forEach((element) {
      if (element.id == uid) {
        t = element.type;
      }
    });
    return t;
  }

//get specific user---------------------------------------------------------
  User? getspecificuser(String uid) {
    User? u;
    print(uid);
    user.forEach((element) {
      if (element.id == uid) {
        u = element;
      }
    });
    return u;
  }

  //fetch user data--------------------------------------------------------
  Future<void> getuser() async {
    final userurl = Uri.parse(
        "https://furniture-ef43b-default-rtdb.firebaseio.com/Users.json");
    try {
      var response = await http.get(userurl);
      var fetcheddta = json.decode(response.body);
      user.clear();
      fetcheddta.forEach((key, element) {
        user.add(User(
            id: element["id"],
            email: element['email'],
            username: element['username'],
            type: element['type'],
            profileurl: element['profileurl']));
      });

      notifyListeners();
    } catch (err) {
      print(err.toString());
    }
  }

// Change user type-----------------------------------------------------------
  Future<void> changetype(String _userid, String _token) async {
    try {
      print("mina");
      final response = await http.get(Uri.parse(
          "https://furniture-ef43b-default-rtdb.firebaseio.com/Users.json"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Iterate over the user data to find the matching user
        String? userIdToUpdate;
        data.forEach((key, value) {
          if (value['id'] == _userid) {
            userIdToUpdate = key;
            print(userIdToUpdate);
            return;
          }
        });

        if (userIdToUpdate != null) {
          final userUrl = Uri.parse(
              "https://furniture-ef43b-default-rtdb.firebaseio.com/Users/$userIdToUpdate.json?auth=$_token");

          // Update the user's profile URL with a PATCH request
          var r = await http.patch(userUrl, body: json.encode({"type": 1}));
          print(r.statusCode);
        } else {
          print("User with ID $_userid not found.");
        }
      } else {
        print("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (err) {
      print(err.toString());
    }
  }

// Change Profile image-------------------------------------------------------
  Future<void> changeprofileimage(
      String _profileurl, String _userid, String _token) async {
    try {
      print("mina");
      final response = await http.get(Uri.parse(
          "https://furniture-ef43b-default-rtdb.firebaseio.com/Users.json"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Iterate over the user data to find the matching user
        String? userIdToUpdate;
        data.forEach((key, value) {
          if (value['id'] == _userid) {
            userIdToUpdate = key;
            return;
          }
        });
        print(userIdToUpdate);
        if (userIdToUpdate != null) {
          final userUrl = Uri.parse(
              "https://furniture-ef43b-default-rtdb.firebaseio.com/Users/$userIdToUpdate.json?auth=$_token");

          // Update the user's profile URL with a PATCH request
          await http.patch(userUrl,
              body: json.encode({"profileurl": _profileurl}));
        } else {
          print("User with ID $_userid not found.");
        }
      } else {
        print("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (err) {
      print("Error while changing profile image: $err");
    }
  }
}
