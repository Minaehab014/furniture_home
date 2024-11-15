import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:furniture_home/Providers/CartProvider.dart';
import 'package:furniture_home/Providers/OrderProvider.dart';
import 'package:furniture_home/Providers/ProductsProvider.dart';
import 'package:furniture_home/Providers/UsersProvider.dart';
import 'package:furniture_home/Users_Screens/UserTabsController.dart';
import 'package:furniture_home/Users_Screens/UsersHomePage.dart';
import 'package:furniture_home/Vendor_screens/TabsControllerScreen.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/auth_screens/SignUpScreen.dart';
import 'package:provider/provider.dart';
import 'package:furniture_home/auth_screens/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:furniture_home/Providers/PushNotifications.dart';

Future _firebaseBackgoundMessaging(RemoteMessage message) async {
  if (message.notification != null) {
    print("some notifications recieved");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
          apiKey: "AIzaSyB7oUROpB1fFDAZnxUPAyDNAyrwB03bpzI",
          appId: "1:232479975507:android:1c62b438fa31d69c73fea6",
          messagingSenderId: "232479975507",
          projectId: "furniture-ef43b",
        ))
      : await Firebase.initializeApp();
  PushNotifications.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgoundMessaging);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => ProductsProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
      ], // Added the missing closing parenthesis here
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (ctx) => UsersTabsController(),
          '/SignUp': (ctx) => SignUpScreen(),
          '/LogIn': (ctx) => LoginScreen(),
          '/TabsControllerScreen': (ctx) => TabsControllerScreen(),
          '/UsersTabsController': (ctx) => UsersTabsController(),
          '/UserHomePage': (ctx) => UsersHomePage()
        },
      ),
    );
  }
}
