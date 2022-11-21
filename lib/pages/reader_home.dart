import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app/pages/cart_page.dart';
import 'package:news_app/pages/login_page.dart';
import 'package:news_app/pages/writer_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'artical_page.dart';

class ReaderHome extends StatefulWidget {
  const ReaderHome({super.key});

  @override
  State<ReaderHome> createState() => _ReaderHomeState();
}

class _ReaderHomeState extends State<ReaderHome> {
  String email = 'email';
  String name = 'name';

  @override
  void initState() {
    setInitialItems();
    super.initState();
  }

  void setInitialItems() async {
    await SharedPreferences.getInstance().then((value) {
      email = value.getString('email')!;
      name = value.getString('name')!;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          backgroundColor: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.black54),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        email,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.black54, width: 2)),
                  child: InkWell(
                    onTap: (() {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => const WriterHome())),
                          (route) => false);
                    }),
                    child: const ListTile(
                      leading: Icon(Icons.edit),
                      title: Text(
                        'Writer Mode',
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.black54, width: 2)),
                  child: InkWell(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      SharedPreferences.getInstance().then((value) {
                        value.remove('name');
                        value.remove('email');
                        value.remove('isWriter');
                        value.remove('login');
                        value.clear();

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const LoginPage())),
                            (route) => false);
                      });
                    },
                    child: const ListTile(
                      leading: Icon(Icons.logout_rounded),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            InkWell(
              onTap: () {
                FirebaseAuth.instance.signOut();
                SharedPreferences.getInstance().then((value) {
                  value.remove('name');
                  value.remove('email');
                  value.remove('isWriter');
                  value.remove('login');
                  value.clear();

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const LoginPage())),
                      (route) => false);
                });
              },
              child: const Icon(Icons.logout_rounded),
            )
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('articals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Articals'));
          }

          if (snapshot.data == null) {
            return const Center(child: Text('No Articals'));
          }

          return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onLongPress: () {
                      DocumentReference<Map<String, dynamic>> doc =
                          FirebaseFirestore.instance
                              .collection('reader')
                              .doc(email);

                      doc.get().then((value) {
                        List list = value.data()!['cart'];
                        if (!list.contains(snapshot.data!.docs[index].id)) {
                          list.add(snapshot.data!.docs[index].id);
                          doc.update({'cart': list});
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.black,
                                  content: Text("Artical added in your cart")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.black,
                                  content: Text(
                                      "Artical is already present in you cart")));
                        }
                      });
                    },
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => ArticalPage(
                                    docs: snapshot.data!.docs[index].data(),
                                  )));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          height: 250,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            image: DecorationImage(
                                image: Image.network(snapshot.data!.docs[index]
                                        .data()['image'])
                                    .image,
                                fit: BoxFit.fill),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: InkWell(
                            onTap: () {
                              DocumentReference<Map<String, dynamic>> doc =
                                  FirebaseFirestore.instance
                                      .collection('reader')
                                      .doc(email);

                              doc.get().then((value) {
                                List list = value.data()!['cart'];
                                if (!list
                                    .contains(snapshot.data!.docs[index].id)) {
                                  list.add(snapshot.data!.docs[index].id);
                                  doc.update({'cart': list});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          backgroundColor: Colors.black,
                                          content: Text(
                                              "Artical added in your cart")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          backgroundColor: Colors.black,
                                          content: Text(
                                              "Artical is already present in you cart")));
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child:
                                    const Icon(Icons.add_shopping_cart_rounded, color: Colors.white,),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              snapshot.data!.docs[index].data()['title'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.shopping_cart_rounded),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => CartPage(email: email))));
        },
      ),
    );
  }
}
