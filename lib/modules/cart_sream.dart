import 'package:cloud_firestore/cloud_firestore.dart';

class CartStream {
  String email;
  List<DocumentSnapshot<Map<String, dynamic>>>? cartItems = [];
  CartStream({required this.email});

  Future<List<DocumentSnapshot<Map<String, dynamic>>>?> getCartStream() async {
    DocumentReference<Map<String, dynamic>> readerDoc =
        FirebaseFirestore.instance.collection('reader').doc(email);

    DocumentSnapshot<Map<String, dynamic>> readerValue = await readerDoc.get();

    List<dynamic> list = readerValue.data()!['cart'];

    for (int i = 0; i < list.length; i++) {
      DocumentSnapshot<Map<String, dynamic>> articalValue =
          await FirebaseFirestore.instance
              .collection('articals')
              .doc(list[i])
              .get();

      cartItems!.add(articalValue);
    }
    return cartItems;
  }
}
