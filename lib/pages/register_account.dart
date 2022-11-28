import 'package:flutter/material.dart';
import 'package:news_app/controllers/database_controller.dart';

import '../controllers/navigation_controller.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});
  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  String email = 'email';
  String pass = 'pass';
  String upi = 'upi';
  String name = 'name';
  bool isDone = true;

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
                padding: const EdgeInsets.all(10.0),
                child: !isDone ? const Center( child: CircularProgressIndicator(),) : ElevatedButton(
                  onPressed: () async {
                    if (isDone) {
                      isDone = false;
                      setState(() {});
                      await Database.registerAccount(
                          context, email, pass, upi, name);
                      isDone = true;
                      setState(() {});
                      Navigation.toReaderHomeAndRemovePrevPages(context);
                    }
                  },
                  child:  const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
