import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/database_controller.dart';
import 'package:news_app/controllers/navigation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriterHome extends StatefulWidget {
  const WriterHome({super.key});

  @override
  State<WriterHome> createState() => _WriterHomeState();
}

class _WriterHomeState extends State<WriterHome> {
  String? name;
  String email = 'email';
  String upi = 'upi';
  List<Object>? articalFields = [];

  @override
  void initState() {
    initialSetter();
    super.initState();
  }

  void initialSetter() async {
    var value = await SharedPreferences.getInstance();
    name = value.getString('name')!;
    email = value.getString('email')!;
    var doc =
        await FirebaseFirestore.instance.collection('user').doc(email).get();
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
                      Navigation.toReaderHomeAndRemovePrevPages(context);
                    }),
                    child: const ListTile(
                      leading: Icon(Icons.read_more),
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
                      Navigation.toLogout(context);
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
                Navigation.toLogout(context);
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
                            Navigation.toArticalPage(
                                context, snapshot.data!.docs, index);
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
                                      fit: BoxFit.cover),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigation.toEditArticalPage(
                                          context, snapshot.data!.docs[index]);
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          color: Colors.black,
                                          borderRadius: const BorderRadius.all(
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
            articalFields =
                await Navigation.toWriteArticalPage(context, name!, email);

            if (articalFields != null) {
              Database.createArtical(articalFields!, upi, name!, email);
            }
          }),
          child: const Center(child: Icon(Icons.edit))),
    );
  }
}
