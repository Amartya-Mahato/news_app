import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app/pages/reader_home.dart';
import 'package:news_app/pages/register_account.dart';
import 'package:news_app/pages/writer_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key, required this.isWriter});
  final bool isWriter;

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  String email = 'email';
  String pass = 'pass';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.isWriter ? 'Writer Login' : 'Reader Login',
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.deepPurple,
                    suffixIcon: const Icon(Icons.mail_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: true,
                  onChanged: (value) {
                    pass = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.deepPurple,
                    suffixIcon: const Icon(Icons.key),
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
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email, password: pass)
                        .then((value) async {
                      SharedPreferences.getInstance().then((pref) {
                        pref.setBool('login', true);
                        pref.setString('email', email);
                        pref.setBool('isWriter', widget.isWriter);

                        FirebaseFirestore.instance
                            .collection(widget.isWriter ? 'writers' : 'reader')
                            .doc(email)
                            .get()
                            .then((documentsnapshot) {
                          pref.setString('name', documentsnapshot['name']);
                          if (widget.isWriter) {
                            pref.setString('upi', documentsnapshot['upi']);
                          }

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => widget.isWriter
                                      ? const WriterHome()
                                      : const ReaderHome()),
                              (route) => false);
                        });
                      });
                    }).onError((error, stackTrace) {});
                  },
                  child: const Text("Next"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterAccount(
                                  isWriter: widget.isWriter,
                                )));
                  },
                  child: const Text("Don't have a account ? Create one here!"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
