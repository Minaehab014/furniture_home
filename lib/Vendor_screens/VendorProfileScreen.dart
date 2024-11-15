import 'package:flutter/material.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/Providers/UsersProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'dart:io';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({Key? key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  XFile? _image;
  bool _isLoading = false;

  Future<void> pickImage_gallery() async {
    var imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = imageFile;
    });
  }

  void initState() {
    super.initState();

    // Fetch data from the ProductsProvider
    fetchData(); // Call fetchData directly without Future.delayed
  }

  void fetchData() async {
    await Provider.of<UserProvider>(context, listen: false).getuser();
  }

  @override
  Widget build(BuildContext context) {
    var userprovider = Provider.of<UserProvider>(context, listen: true);
    var authprovider = Provider.of<AuthProvider>(context, listen: true);
    var user = userprovider.getspecificuser(authprovider.UserId);

    Future<void> UploadData() async {
      try {
        setState(() {
          _isLoading = true;
        });
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference reference = storage.ref().child(p.basename(_image!.path));
        UploadTask upload = reference.putFile(File(_image!.path));
        TaskSnapshot snapshot = await upload;
        String imageUrl = await snapshot.ref.getDownloadURL();

        await Provider.of<UserProvider>(context, listen: false)
            .changeprofileimage(
                imageUrl, authprovider.UserId, authprovider.token);
        setState(() {
          _image = null;
          _isLoading = false;
        });
      } catch (err) {
        print(err.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        await userprovider.getuser();
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              CircularProgressIndicator() // Show loading indicator while uploading
            else if (user != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.profileurl),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwj4ygYYQAkEIdobMRStVQmqr0HUwbU5p0LgjnCidQBw&s'),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            user != null
                ? Text(
                    user.username, // User name
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    "",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            user != null
                ? Text(
                    "Email: ${user.email}",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )
                : Text(
                    "",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
            user != null
                ? user.type == 0
                    ? Row(
                        children: [
                          SizedBox(
                            width: 140,
                          ),
                          Text(
                            "user",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                              onPressed: () async {
                                await userprovider.changetype(
                                    authprovider.UserId, authprovider.token);
                                Navigator.pop(context);
                                Navigator.of(context).pushNamed("/LogIn");
                              },
                              child: Text("Change Type"))
                        ],
                      )
                    : Text("Vendor")
                : Text(""),
            authprovider.isAuthanticated
                ? Row(
                    children: [
                      SizedBox(
                        width: 130,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            await UploadData();
                            await userprovider.getuser();
                            user = await userprovider
                                .getspecificuser(authprovider.UserId);
                          },
                          child: Text("Update Photo")),
                      IconButton(
                          onPressed: pickImage_gallery,
                          icon: Icon(Icons.photo_album_rounded))
                    ],
                  )
                : Text("You Can SignIn"),
            SizedBox(height: 20),
            authprovider.isAuthanticated
                ? Text("")
                : ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed("/LogIn");
                    },
                    child: Text('Sign In'),
                  ),
          ],
        ),
      ),
    );
  }
}
