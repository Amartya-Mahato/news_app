import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app/pages/reader_home.dart';
import 'package:news_app/pages/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? login = prefs.getBool('login');

  runApp(MaterialApp(
    title: 'News App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.black,
    ),
    home: login == null
        ? const UserLogin()
        : const ReaderHome(),
  ));
}
