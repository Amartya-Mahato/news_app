import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/database_controller.dart';
import 'package:news_app/controllers/navigation_controller.dart';
import 'package:news_app/modules/cart_sream.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key, required this.email});
  final String email;

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? cartItems;

  @override
  void initState() {
    initializeItems();
    super.initState();
  }

  void initializeItems() async {
    cartItems = await CartStream(email: widget.email).getCartStream();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade600,
          title: Row(
            children: [
              const Text(
                'Bookmark',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              Text('Total items ${cartItems == null ? 0 : cartItems!.length}',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        body: cartItems == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: cartItems!.length,
                itemBuilder: ((context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
                        Navigation.toArticalPage(context, cartItems!, index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.grey,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        height: 50,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 70,
                                child: Text(
                                  cartItems![index].data()['title'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.normal,
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  cartItems = await Database.deleteBookmark(
                                      widget.email,
                                      cartItems![index].id,
                                      cartItems!,
                                      index);
                                  setState(() {});
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })));
  }
}
