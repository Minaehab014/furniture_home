import 'package:flutter/material.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  void signIn() async {
    try {
      var _email = emailController.text.trim();
      var _password = passwordController.text.trim();
      var successOrError =
          await Provider.of<AuthProvider>(context, listen: false)
              .signin(em: _email, pass: _password);
      print(successOrError['type']);
      if (_email.isEmpty || _password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successOrError['mssg']),
          ),
        );
      } else if (successOrError['mssg'] != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successOrError['mssg']),
          ),
        );
      } else {
        if (successOrError['type'] == 0) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/UsersTabsController');
          print("mina");
        } else if (successOrError['type'] == 1) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/TabsControllerScreen');
        } else {
          print("Mina");
        }
      }
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            ElevatedButton(
              onPressed: signIn,
              child: Text("Sign in"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/SignUp');
              },
              child: Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
