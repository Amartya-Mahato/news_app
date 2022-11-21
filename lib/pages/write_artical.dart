import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WriteArtical extends StatefulWidget {
  const WriteArtical({super.key, required this.email, required this.name});
  final String email;
  final String name;

  @override
  State<WriteArtical> createState() => _WriteArticalState();
}

class _WriteArticalState extends State<WriteArtical> {
  String title = 'title';
  String discription = 'discription';
  int fee = 0;
  int disFee = 0;
  bool isUploading = false;
  bool initialUpload = false;
  String imageUrl = 'imgUrl';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: const Text(
          'Write Artical',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(
                  hintText: 'Title',
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
                  hintText: 'Fee',
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
                  hintText: 'Discounted Fee',
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
                          imageUrl = await FirebaseStorage.instance
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
                  hintText: 'Discription',
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
                  if (initialUpload && !isUploading) {
                    Navigator.pop(
                        context, [imageUrl, title, fee, disFee, discription]);
                  }
                },
                child: const Text("Next"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
