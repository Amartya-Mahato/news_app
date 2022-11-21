import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app/pages/artical_page.dart';
import 'package:news_app/pages/edit_page.dart';
import 'package:news_app/pages/reader_home.dart';
import 'package:news_app/pages/write_artical.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class WriterHome extends StatefulWidget {
  const WriterHome({super.key});

  @override
  State<WriterHome> createState() => _WriterHomeState();
}

class _WriterHomeState extends State<WriterHome> {
  String? name;
  String email = 'email';
  String upi = 'upi';
  bool isWriter = true;
  List<Object>? articalFields = [];

  @override
  void initState() {
    initialSetter();
    super.initState();
  }

  void initialSetter() async {
    var value = await SharedPreferences.getInstance();
    name = value.getString('name')!;
    isWriter = value.getBool('isWriter')!;
    email = value.getString('email')!;
    var doc =
        await FirebaseFirestore.instance.collection('writers').doc(email).get();
    upi = doc.data()!['upi'];
    value.setString('upi', upi);
    setState(() {});
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
                        name == null ? "Loading" : name!,
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
                              builder: ((context) => const ReaderHome())),
                          (route) => false);
                    }),
                    child: const ListTile(
                      leading: Icon(Icons.edit),
                      title: Text(
                        'Reader Mode',
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
            Text(name == null ? "Loading" : name!),
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
      body: name == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('articals')
                  .where('email', isEqualTo: email)
                  .snapshots(),
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
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => ArticalPage(
                                          docs:
                                              snapshot.data!.docs[index].data(),
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
                                      image: Image.network(snapshot
                                              .data!.docs[index]
                                              .data()['image'])
                                          .image,
                                      fit: BoxFit.fill),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) => EditPage(
                                                  snapshot: snapshot
                                                      .data!.docs[index]))));
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
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
          onPressed: (() async {
            articalFields = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => WriteArtical(
                          name: name!,
                          email: email,
                        ))));
            if (articalFields != null) {
              var document =
                  FirebaseFirestore.instance.collection('articals').doc();
              document.set({
                'discount_fee': articalFields![3] as int,
                'discription': articalFields![4] as String,
                'fee': articalFields![2] as int,
                'image': articalFields![0] as String,
                'title': articalFields![1] as String,
                'upi': upi,
                'writer': name,
                'email': email,
              });

              FirebaseFirestore.instance
                  .collection('writers')
                  .doc(email)
                  .get()
                  .then((value) async {
                Map<String, dynamic> mpp = value.data()!;
                mpp['artical'].add(document.id);
                await FirebaseFirestore.instance
                    .collection('writers')
                    .doc(email)
                    .update({'artical': mpp['artical']});
              });
            }
          }),
          child: const Center(child: Icon(Icons.edit))),
    );
  }
}
