import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class Firebasecrud extends StatefulWidget {
  const Firebasecrud({super.key});

  @override
  State<Firebasecrud> createState() => _FirebasecrudState();
}

class _FirebasecrudState extends State<Firebasecrud> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection("piccrud");
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController idcontroller = TextEditingController();
  final TextEditingController fieldcontroller = TextEditingController();
  final TextEditingController sectioncontroller = TextEditingController();
  @override
  Future<void> create() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyDialogBox(
            name: "Add Data",
            condition: "Add",
            onPressed: () {
              String name = namecontroller.text;
              String id = idcontroller.text;
              String field = fieldcontroller.text;
              String section = sectioncontroller.text;
              Additems(name, id, field, section);
              Navigator.pop(context);
            });
      },
    );
  }

  // Add items
  void Additems(String name, String id, String field, String section) async {
    myItems.add({'name': name, 'id': id, 'field': field, 'section': section});
  }

  String? imageURL;

  // Image Picker
  final ImagePicker _imagepicker = ImagePicker();
  Future<void> PickImage() async {
    try {
      XFile? res = await _imagepicker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        await uploadImagetoFirebase(File(res.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Image Loaded Failed"),
      ));
    }
  }

  Future<void> uploadImagetoFirebase(File image) async {
    try {
      Reference reference = FirebaseStorage.instance
          .ref()
          .child("images/${DateTime.now().microsecondsSinceEpoch}.png");
      await reference.putFile(image).whenComplete(() {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Image has been loaded Successfully")));
      });
      imageURL = await reference.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red, content: Text("Image Loaded Failed")));
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    try {
      // Create a reference to the location where you want to upload the image
      Reference reference = FirebaseStorage.instance
          .ref()
          .child("images/${DateTime.now().microsecondsSinceEpoch}.png");

      // Upload the image to Firebase Storage
      await reference.putFile(image).whenComplete(() {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Image has been loaded successfully"),
        ));
      });

      // Get the download URL of the uploaded image
      imageURL = await reference.getDownloadURL();
    } catch (e) {
      // Handle any errors during image upload
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Image Upload Failed: ${e.toString()}"),
      ));
    }
  }

// Edit the Text
  Future<void> update(DocumentSnapshot documentsnapshot) async {
    namecontroller.text = documentsnapshot['name'];
    idcontroller.text = documentsnapshot['id'];
    fieldcontroller.text = documentsnapshot['field'];
    sectioncontroller.text = documentsnapshot['section'];
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyDialogBox(
            name: "Update Date",
            condition: "Update",
            onPressed: () async {
              String name = namecontroller.text;
              String id = idcontroller.text;
              String field = fieldcontroller.text;
              String section = sectioncontroller.text;
              myItems.doc(documentsnapshot.id).update(
                  {'name': name, 'id': id, "field": field, "section": section});
              namecontroller.text = '';
              idcontroller.text = '';
              fieldcontroller.text = '';
              sectioncontroller.text = '';
              Navigator.pop(context);
            });
      },
    );
  }

  // Delete the text
  Future<void> delete(String picid) async {
    await myItems.doc(picid).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 200),
        content: Text("Data has been deleted successfully")));
  }

  bool isSearch = false;
  String SearchText = '';
  void onSearchChange(String value) {
    setState(() {
      SearchText = value;
    });
  }

  final TextEditingController SearchController = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        title: isSearch
            ? Container(
                height: 45,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: SearchController,
                  onChanged: onSearchChange,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: "Search...",
                      hintStyle: TextStyle(color: Colors.black),
                      contentPadding: EdgeInsets.fromLTRB(16, 16, 20, 12)),
                ),
              )
            : const Text(
                "WhatsApp",
                style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isSearch = !isSearch;
                });
              },
              icon: Icon(isSearch ? Icons.close : Icons.search,
                  color: Colors.white))
        ],
      ),
      body: StreamBuilder(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> StreamSnapshot) {
          if (StreamSnapshot.hasData) {
            final List<DocumentSnapshot> myItems = StreamSnapshot.data!.docs
                .where((docs) => docs['name']
                    .toLowerCase()
                    .contains(SearchText.toLowerCase()))
                .toList();
            return ListView.builder(
              itemCount: myItems.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = myItems[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/background.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Material(
                        elevation: 10.0,
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 100.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                      radius: 30,
                                      child: imageURL == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 20,
                                              color: Colors.white,
                                            )
                                          : SizedBox(
                                              height: 60,
                                              width: 100,
                                              child: ClipOval(
                                                child: Image.network(
                                                  imageURL!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )),
                                  Positioned(
                                    left: 34,
                                    right: 20,
                                    top: 30,
                                    child: GestureDetector(
                                      onTap: () {
                                        PickImage();
                                      },
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey,
                                        size: 25,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                documentSnapshot['name'],
                                style: const TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () => update(documentSnapshot),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          delete(documentSnapshot.id),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: create,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }

  Dialog MyDialogBox(
          {required String name,
          required String condition,
          required VoidCallback onPressed}) =>
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Stack(
                    children: [
                      CircleAvatar(
                          radius: 30,
                          child: imageURL == null
                              ? const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.white,
                                )
                              : SizedBox(
                                  height: 60,
                                  width: 100,
                                  child: ClipOval(
                                    child: Image.network(
                                      imageURL!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )),
                      Positioned(
                        left: 34,
                        right: 20,
                        top: 30,
                        child: GestureDetector(
                          onTap: () {
                            PickImage();
                          },
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                            size: 25,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: namecontroller,
                    cursorColor: Colors.greenAccent,
                    decoration: InputDecoration(
                        labelText: "Enter your name",
                        hintText: "e.g john",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent))),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: idcontroller,
                    cursorColor: Colors.greenAccent,
                    decoration: InputDecoration(
                        labelText: "Enter your id",
                        hintText: "e.g 2",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent))),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: fieldcontroller,
                    cursorColor: Colors.greenAccent,
                    decoration: InputDecoration(
                        labelText: "Enter your Field",
                        hintText: "e.g IT",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent))),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: sectioncontroller,
                    cursorColor: Colors.greenAccent,
                    decoration: InputDecoration(
                        labelText: "Enter your section",
                        hintText: "e.g A",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent))),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent),
                      child: Text(
                        condition,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ))
                ],
              ),
            ),
          ),
        ),
      );
}
