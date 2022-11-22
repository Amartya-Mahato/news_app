import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/database.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key, required this.snapshot});
  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool isUploading = false;
  bool initialUpload = false;
  String? title;
  String? discription;
  int? likes;
  int? amount;
  String? upi;
  String? image;
  String? writer;
  String? email;
  List? liked;

  @override
  void initState() {
    initialSetter();
    super.initState();
  }

  void initialSetter() {
    Map<String, dynamic> data = widget.snapshot.data();
    title = data['title'];
    discription = data['discription'];
    amount = data['amount'];
    image = data['image'];
    upi = data['upi'];
    writer = data['writer'];
    email = data['email'];
    likes = data['likes'];
    liked = data['liked'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: Row(children: [
          const Text(
            'Edit',
            style: TextStyle(color: Colors.white),
          ),
          const Spacer(),
          InkWell(
            onTap: (() async {
              Database.deleteArtical(context, widget.snapshot, email!);
            }),
            child: Icon(
              Icons.delete,
              color: Colors.red.shade700,
            ),
          )
        ]),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLength: 50,
              onChanged: (value) {
                title = value;
              },
              decoration: InputDecoration(
                hintText: title,
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.deepPurple,
                suffixIcon: const Icon(Icons.bookmark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                amount = int.parse(value);
              },
              decoration: InputDecoration(
                hintText: amount.toString(),
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.deepPurple,
                suffixIcon: const Icon(Icons.discount_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () async {
                  FilePicker.platform
                      .pickFiles(type: FileType.image, withData: true)
                      .then((file) {
                    if (file != null) {
                      initialUpload = true;
                      isUploading = true;
                      setState(() {});
                      Uint8List fileBytes = file.files.first.bytes!;
                      String fileName = file.files.first.name;
                      FirebaseStorage.instance
                          .ref('uploads/$fileName')
                          .putData(fileBytes)
                          .then((p0) async {
                        image = await FirebaseStorage.instance
                            .ref('uploads/$fileName')
                            .getDownloadURL();
                        isUploading = false;
                        setState(() {});
                      });
                    } else {
                      initialUpload = false;
                      isUploading = false;
                      setState(() {});
                    }
                  });
                },
                child: initialUpload
                    ? isUploading
                        ? const Text("Uploading...")
                        : const Text("Uploaded")
                    : const Text("Upload")),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLines: 15,
              onChanged: (value) {
                discription = value;
              },
              decoration: InputDecoration(
                hintText: discription,
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.deepPurple,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Database.appyEdits(
                    isUploading,
                    context,
                    widget.snapshot,
                    image!,
                    amount!,
                    discription!,
                    title!,
                    upi!,
                    likes!,
                    writer!,
                    liked!,
                    email!);
              },
              child: const Text("Apply"),
            ),
          )
        ],
      )),
    );
  }
}
