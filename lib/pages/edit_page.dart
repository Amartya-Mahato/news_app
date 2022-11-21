import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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
  int? fee;
  int? disFee;
  String? upi;
  String? image;
  String? writer;
  String? email;

  @override
  void initState() {
    initialSetter();
    super.initState();
  }

  void initialSetter() {
    Map<String, dynamic> data = widget.snapshot.data();
    title = data['title'];
    discription = data['discription'];
    fee = data['fee'];
    disFee = data['discount_fee'];
    image = data['image'];
    upi = data['upi'];
    writer = data['writer'];
    email = data['email'];
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
              // Remove the artical
              FirebaseFirestore.instance
                  .collection('articals')
                  .doc(widget.snapshot.id)
                  .delete();

              //Remove from writer account
              var doc =
                  FirebaseFirestore.instance.collection('writers').doc(email);
              var snapshot = await doc.get();
              List list = snapshot.data()!['artical'];
              list.remove(widget.snapshot.id);
              await doc.update({'artical': list});

              // Remove from reader's account
              var query = FirebaseFirestore.instance
                  .collection('reader')
                  .where('cart', arrayContains: widget.snapshot.id);
              var querySnapshot = await query.get();
              List<QueryDocumentSnapshot<Map<String, dynamic>>> queryList =
                  querySnapshot.docs;
              for (int i = 0; i < queryList.length; i++) {
                List cartList = queryList[i].data()['cart'];
                cartList.remove(widget.snapshot.id);
                await FirebaseFirestore.instance
                    .collection('reader')
                    .doc(queryList[i].id)
                    .update({'cart': cartList});
              }

              //Remove the image
              FirebaseStorage.instance
                  .refFromURL(widget.snapshot.data()['image'])
                  .delete();

              Navigator.pop(context);
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
                fee = int.parse(value);
              },
              decoration: InputDecoration(
                hintText: fee.toString(),
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.deepPurple,
                suffixIcon: const Icon(Icons.monetization_on_rounded),
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
                disFee = int.parse(value);
              },
              decoration: InputDecoration(
                hintText: disFee.toString(),
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
                if (image != widget.snapshot.data()['image']) {
                  FirebaseStorage.instance
                      .refFromURL(widget.snapshot.data()['image'])
                      .delete();
                }
                FirebaseFirestore.instance
                    .collection('articals')
                    .doc(widget.snapshot.id)
                    .set({
                  'discount_fee': disFee,
                  'discription': discription,
                  'fee': fee,
                  'image': image,
                  'title': title,
                  'upi': upi,
                  'writer': writer,
                  'email': email,
                });

                if (!isUploading) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Apply"),
            ),
          )
        ],
      )),
    );
  }
}
