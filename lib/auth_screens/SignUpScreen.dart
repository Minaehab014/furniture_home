import 'package:flutter/material.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController username;
  List<String> types = ["user", "vendor"];
  String Selected_type = "user";

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    username = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    username.dispose();
    super.dispose();
  }

  void signUp() async {
    try {
      var _email = emailController.text.trim();
      var _password = passwordController.text.trim();
      var _username = username.text.trim();
      var successOrError =
          await Provider.of<AuthProvider>(context, listen: false)
              .signup(em: _email, pass: _password, uname: _username, t: 0);

      if (_email.isEmpty || _password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successOrError),
          ),
        );
      } else if (successOrError != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successOrError),
          ),
        );
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/UsersTabsController');
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: username,
                decoration: InputDecoration(
                  hintText: 'UserName',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
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
              onPressed: signUp,
              child: Text("Sign up"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/');
              },
              child: Text("Already have an account? Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}
