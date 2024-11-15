import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String _token = "";
  bool _isAuth = false;
  DateTime _expiryDate = DateTime.utc(1970);
  String _userId = "";

  bool get isAuthanticated => _isAuth;

  String get token {
    if (_expiryDate != DateTime.utc(1970) &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != "") {
      return _token;
    }
    return "";
  }

  String get UserId => _userId;

  Future<String> signup(
      {required String em,
      required String pass,
      required String uname,
      required int t}) async {
    final url = Uri.parse(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyBG2HDQwbgRzK6pxuzFmHkPvHWQeAH4Pec');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': em,
            'password': pass,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        return responseData['error']['message'];
      } else {
        _isAuth = true;
        _userId = responseData['localId'];
        print(_userId);
        _token = responseData['idToken'];
        _expiryDate = DateTime.now().add(
          Duration(
            seconds: int.parse(
              responseData['expiresIn'],
            ),
          ),
        );
        final users_url = Uri.parse(
            "https://furniture-ef43b-default-rtdb.firebaseio.com/Users.json?auth=$_token");
        await http.post(users_url,
            body: json.encode({
              'id': _userId,
              'email': em,
              'username': uname,
              'type': t,
              'profileurl':
                  "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg"
            }));

        print(
            _isAuth.toString() + " " + _userId + " " + _expiryDate.toString());
        notifyListeners();
        return "success";
      }
    } catch (err) {
      print("The error is: " + err.toString());
      return err.toString();
    }
  }

  Future<Map<String, dynamic>> signin(
      {required String em, required String pass}) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBG2HDQwbgRzK6pxuzFmHkPvHWQeAH4Pec');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': em,
            'password': pass,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        return {'mssg': responseData['error']['message'] as String, "type": -1};
      } else {
        _isAuth = true;
        _token = responseData['idToken'];

        _userId = responseData['localId'];
        _expiryDate = DateTime.now().add(
          Duration(
            seconds: int.parse(
              responseData['expiresIn'],
            ),
          ),
        );
        final res = await http.get(Uri.parse(
            "https://furniture-ef43b-default-rtdb.firebaseio.com/Users.json"));
        var fetchedres = json.decode(res.body);
        int userType = -1;
        fetchedres.forEach((key, value) {
          if (value['id'] == _userId) {
            userType = value['type'];
            print(value);
          }
        });
        print(
            _isAuth.toString() + " " + _userId + " " + _expiryDate.toString());
        notifyListeners();
        return {"mssg": "success", "type": userType};
      }
    } catch (err) {
      print("The error is: " + err.toString());
      throw err;
    }
  }
}
