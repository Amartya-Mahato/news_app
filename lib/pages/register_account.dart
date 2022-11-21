import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app/pages/reader_home.dart';
import 'package:news_app/pages/writer_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key, required this.isWriter});
  final bool isWriter;
  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  String email = 'email';
  String pass = 'pass';
  String upi = 'upi';
  String name = 'name';

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
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Register your account',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.deepPurple,
                    suffixIcon: const Icon(Icons.person),
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
                child: TextField(
                  onChanged: (value) {
                    upi = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Upi',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.deepPurple,
                    suffixIcon: const Icon(Icons.shield_rounded),
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
                        .createUserWithEmailAndPassword(
                            email: email, password: pass)
                        .then((value) {
                      SharedPreferences.getInstance().then((pref) {
                        pref.setBool('login', true);
                        pref.setString('email', email);
                        pref.setBool('isWriter', widget.isWriter);
                        pref.setString('name', name);
                        pref.setString('upi', upi);

                        FirebaseFirestore.instance
                            .collection('writers')
                            .doc(email)
                            .set({
                          'artical': [],
                          'name': name,
                          'upi': upi
                        }).then((_) {
                          FirebaseFirestore.instance
                              .collection('reader')
                              .doc(email)
                              .set({'cart': [], 'name': name}).then((_) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => widget.isWriter
                                        ? const WriterHome()
                                        : const ReaderHome()),
                                (route) => false);
                          });
                        });
                      });
                    }).onError((error, stackTrace) {});
                  },
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
