import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/navigation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Database {
  static Future<int> updateLikes(int prevLike, String id) async {
    int likes = prevLike;

    DocumentReference<Map<String, dynamic>> doc =
        FirebaseFirestore.instance.collection('articals').doc(id);

    var snapshot = await doc.get();
    List? snapList = snapshot.data()!['liked'];
    snapList ??= [];
    var pref = await SharedPreferences.getInstance();

    if (!snapList.contains(pref.getString('email')) || likes <= 0) {
      snapList.add(pref.getString('email'));
      await doc.update({'likes': likes + 1, 'liked': snapList});
      likes = likes + 1;
    } else {
      snapList.remove(pref.getString('email'));
      await doc.update({'likes': likes - 1, 'liked': snapList});
      likes = likes - 1;
    }
    return likes;
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      deleteBookmark(
          String email,
          String id,
          List<QueryDocumentSnapshot<Map<String, dynamic>>> cartItems,
          int index) async {
    var doc = FirebaseFirestore.instance.collection('user').doc(email);

    List<dynamic> list;
    var instance = await doc.get();
    list = instance.data()!['bookmark'];
    list.remove(cartItems[index].id);
    cartItems.remove(cartItems[index]);
    await doc.update({'bookmark': list});

    return cartItems;
  }

  static void appyEdits(
      bool isUploading,
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
      String image,
      int amount,
      String discription,
      String title,
      String upi,
      int likes,
      String writer,
      List liked,
      String email) {
    if (image != snapshot.data()['image']) {
      FirebaseStorage.instance.refFromURL(snapshot.data()['image']).delete();
    }
    FirebaseFirestore.instance.collection('articals').doc(snapshot.id).set({
      'amount': amount,
      'discription': discription,
      'image': image,
      'title': title,
      'upi': upi,
      'likes': likes,
      'writer': writer,
      'liked': liked,
      'email': email,
    });

    if (!isUploading) {
      Navigator.pop(context);
    }
  }

  static void deleteArtical(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
      String email) async {
    // Remove the artical
    FirebaseFirestore.instance.collection('articals').doc(snapshot.id).delete();

    //Remove from writer account
    var doc = FirebaseFirestore.instance.collection('user').doc(email);
    var snap = await doc.get();
    List list = snap.data()!['articals'];
    list.remove(snapshot.id);
    await doc.update({'articals': list});

    // Remove from reader's account
    var query = FirebaseFirestore.instance
        .collection('user')
        .where('bookmark', arrayContains: snapshot.id);
    var querySnapshot = await query.get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> queryList =
        querySnapshot.docs;
    for (int i = 0; i < queryList.length; i++) {
      List cartList = queryList[i].data()['bookmark'];
      cartList.remove(snapshot.id);
      await FirebaseFirestore.instance
          .collection('user')
          .doc(queryList[i].id)
          .update({'bookmark': cartList});
    }

    //Remove the image
    FirebaseStorage.instance.refFromURL(snapshot.data()['image']).delete();

    Navigator.pop(context);
  }

  static void addToBookmark(BuildContext context, String email, String id) {
    DocumentReference<Map<String, dynamic>> doc =
        FirebaseFirestore.instance.collection('user').doc(email);

    doc.get().then((value) {
      List list = value.data()!['bookmark'];
      if (!list.contains(id)) {
        list.add(id);
        doc.update({'bookmark': list});

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.black,
            content: Text("Artical added in your cart")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.black,
            content: Text("Artical is already present in you cart")));
      }
    });
  }

  static Future<void> registerAccount(BuildContext context, String email,
      String pass, String upi, String name) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: pass);
    var pref = await SharedPreferences.getInstance();
    pref.setBool('login', true);
    pref.setString('email', email);
    pref.setString('name', name);
    pref.setString('upi', upi);

    await FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .set({'bookmark': [], 'articals': [], 'name': name, 'upi': upi});
  }

  static void loginAccount(BuildContext context, String email, String pass) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((value) async {
      SharedPreferences.getInstance().then((pref) {
        pref.setBool('login', true);
        pref.setString('email', email);

        FirebaseFirestore.instance
            .collection('user')
            .doc(email)
            .get()
            .then((documentsnapshot) {
          pref.setString('name', documentsnapshot['name']);
          pref.setString('upi', documentsnapshot['upi']);

          Navigation.toReaderHomeAndRemovePrevPages(context);
        });
      });
    }).onError((error, stackTrace) {});
  }

  static void createArtical(
      List<Object?> articalFields, String upi, String name, String email) {
    var document = FirebaseFirestore.instance.collection('articals').doc();
    document.set({
      'amount': articalFields[2] as int,
      'discription': articalFields[3] as String,
      'image': articalFields[0] as String,
      'title': articalFields[1] as String,
      'upi': upi,
      'writer': name,
      'likes': 0,
      'liked': [],
      'email': email,
    });

    FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .get()
        .then((value) async {
      Map<String, dynamic> mpp = value.data()!;
      mpp['articals'].add(document.id);
      await FirebaseFirestore.instance
          .collection('user')
          .doc(email)
          .update({'articals': mpp['articals']});
    });
  }
}
