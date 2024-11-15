import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:furniture_home/Providers/AuthProvider.dart';
import 'package:furniture_home/Providers/ProductsProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import 'dart:io';
import 'package:provider/provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:firebase_core/firebase_core.dart';

class VendorAddScreen extends StatefulWidget {
  const VendorAddScreen({super.key});

  @override
  State<VendorAddScreen> createState() => _VendorAddScreenState();
}

class _VendorAddScreenState extends State<VendorAddScreen> {
  List<String> cat = ["Living Room", "Kitchen", "Bedroom"];
  List<String> sub_cat = ["Furniture", "Decorations"];
  String selected_cat = "Living Room";
  String selected_sub_cat = "Furniture";

  late TextEditingController Price;
  late TextEditingController Description;
  late TextEditingController Quantity;

  @override
  void initState() {
    super.initState();
    Price = TextEditingController();
    Description = TextEditingController();
    Quantity = TextEditingController();
  }

  @override
  void dispose() {
    Price.dispose();
    Description.dispose();
    Quantity.dispose();
    super.dispose();
  }

  XFile? _image;

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: true);
    var productprovider = Provider.of<ProductsProvider>(context, listen: true);

    void UploadData() async {
      try {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference reference = storage.ref().child(p.basename(_image!.path));
        UploadTask upload = reference.putFile(File(_image!.path));
        TaskSnapshot snapshot = await upload;
        String imageUrl = await snapshot.ref.getDownloadURL();
        if (Description.text.isEmpty ||
            Price.text.isEmpty ||
            Quantity.text.isEmpty ||
            _image == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill in all fields.'),
            ),
          );
          return;
        }
        productprovider.addProduct(
            authprovider.UserId,
            int.parse(Quantity.text),
            imageUrl,
            double.parse(Price.text),
            Description.text,
            selected_cat,
            selected_sub_cat,
            authprovider.token,
            5,
            1);
        // Clear form fields after upload
        Price.clear();
        Description.clear();
        Quantity.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product uploaded successfully'),
          ),
        );
        setState(() {
          _image = null;
        });
      } catch (err) {
        print(err.toString());
      }
    }

    void pickImage_camera() async {
      var Image_File =
          await ImagePicker().pickImage(source: ImageSource.camera);

      setState(() {
        _image = Image_File;
      });
    }

    void pickImage_gallery() async {
      var Image_File =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _image = Image_File;
      });
    }

    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: 400,
                  color: const Color.fromARGB(255, 240, 240, 240),
                  child: _image == null
                      ? Center(
                          child: Text('No image selected.'),
                        )
                      : Image.file(
                          File(_image!.path), // Convert XFile to File
                          fit: BoxFit
                              .contain, // Adjust the image size to fit the container
                        ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: pickImage_camera,
                      icon: Icon(Icons.camera_alt_rounded),
                    ),
                    IconButton(
                      onPressed: pickImage_gallery,
                      icon: Icon(Icons.photo_library),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLines: 2,
                controller: Description,
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: Price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: Quantity,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selected_cat,
                  underline: Container(
                    height: 2,
                    color: Theme.of(context)
                        .primaryColor, // Customize underline color
                  ),
                  icon: Icon(Icons.arrow_drop_down), // Customize dropdown icon
                  elevation: 8,
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .color), // Customize text color
                  onChanged: (String? newValue) {
                    setState(() {
                      selected_cat = newValue!;
                      print(selected_cat);
                    });
                  },
                  items: cat.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selected_sub_cat,
                  underline: Container(
                    height: 2,
                    color: Theme.of(context)
                        .primaryColor, // Customize underline color
                  ),
                  icon: Icon(Icons.arrow_drop_down), // Customize dropdown icon
                  elevation: 8,
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .color), // Customize text color
                  onChanged: (String? newValue) {
                    setState(() {
                      selected_sub_cat = newValue!;
                      print(selected_sub_cat);
                    });
                  },
                  items: sub_cat.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.all(10),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: UploadData,
              child: SizedBox(
                // Make button width infinity
                width: 400,
                child: Center(
                    child: Text(
                  "Upload",
                  style: TextStyle(fontSize: 13),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
