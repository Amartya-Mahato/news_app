import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/artical_page.dart';
import '../pages/bookmark_page.dart';
import '../pages/edit_page.dart';
import '../pages/reader_home.dart';
import '../pages/register_account.dart';
import '../pages/user_login.dart';
import '../pages/write_artical.dart';
import '../pages/writer_home.dart';

class Navigation {
  static void toLoginPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: ((context) => const UserLogin())),
        (route) => false);
  }

  static void toLogout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    SharedPreferences.getInstance().then((value) {
      value.remove('name');
      value.remove('email');
      value.remove('login');
      value.clear();

      Navigation.toLoginPage(context);
    });
  }

  static void toRegisterPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RegisterAccount()));
  }

  static void toArticalPage(BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> cartItems, int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => ArticalPage(snapshot: cartItems[index]))));
  }

  static void toBookmarkPage(BuildContext context, String email) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => BookmarkPage(email: email))));
  }

  static void toEditArticalPage(BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => EditPage(snapshot: snapshot))));
  }

  static Future<List<Object>?> toWriteArticalPage(
      BuildContext context, String name, String email) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => WriteArtical(
                  name: name,
                  email: email,
                ))));
  }

  static void toReaderHomeAndRemovePrevPages(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ReaderHome()),
        (route) => false);
  }

  static void toWriterHomeAndRemovePrevPages(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: ((context) => const WriterHome())),
        (route) => false);
  }
}
