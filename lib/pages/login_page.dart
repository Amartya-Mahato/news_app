import 'package:flutter/material.dart';
import 'package:news_app/pages/user_login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            const Text('Choose Your Login Type', style: TextStyle(fontSize: 30),),
            const SizedBox(height: 40,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserLogin(
                          isWriter: true,
                        ),
                      ));
                },
                child: const Text("Writer Login")),
            ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserLogin(
                          isWriter: false,
                        ),
                      ));
                },
                child: const Text("Reader Login")),
          ]),
        ),
      ),
    );
  }
}
