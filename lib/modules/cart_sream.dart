import 'package:cloud_firestore/cloud_firestore.dart';

class CartStream {
  String email;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? bookmarkItems = [];
  CartStream({required this.email});

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?>
      getCartStream() async {
    var readerDoc = FirebaseFirestore.instance.collection('user').doc(email);
    var readerValue = await readerDoc.get();
    var list = readerValue.data()!['bookmark'];

    for (int i = 0; i < list.length; i++) {
      var coll = await FirebaseFirestore.instance.collection('articals').get();
      var snap = coll.docs.where(((element) => element.id == list[i]));
      bookmarkItems!.add(snap.first);
    }
    return bookmarkItems;
  }
}
