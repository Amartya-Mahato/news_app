import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/database_controller.dart';
import 'package:upi_india/upi_india.dart';

class ArticalPage extends StatefulWidget {
  const ArticalPage({super.key, required this.snapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  @override
  State<ArticalPage> createState() => _ArticalPageState();
}

class _ArticalPageState extends State<ArticalPage> {
  UpiIndia _upiIndia = UpiIndia();
  int likes = 0;
  List<UpiApp>? apps;
  String pay = 'Pay';

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });

    likes = widget.snapshot.data()['likes'];

    super.initState();
  }

  Future<UpiResponse> initiateTransaction(
      UpiApp app,
      String receiverUpiId,
      String receiverName,
      String transactionRefId,
      String transactionNote,
      double amount) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: receiverUpiId,
      receiverName: receiverName,
      transactionRefId: transactionRefId,
      transactionNote: transactionNote,
      amount: amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Artical',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade600, width: 2),
                color: Colors.grey,
                image: DecorationImage(
                    image: Image.network(
                      widget.snapshot.data()['image'],
                    ).image,
                    fit: BoxFit.fill),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              widget.snapshot.data()['title'],
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontStyle: FontStyle.normal),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              'Writer: ${widget.snapshot.data()['writer']}',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
          InkWell(
              onTap: () async {
                likes = await Database.updateLikes(likes, widget.snapshot.id);
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, top: 8),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.green.shade700, width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.green.shade200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thumb_up_alt_rounded,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(
                        width: 5,
                        height: 30,
                      ),
                      SizedBox(
                        child: Text(
                          '$likes',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.blue.shade600, width: 2)),
              alignment: Alignment.topCenter,
              padding:
                  const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
              child: Text(
                widget.snapshot.data()['discription'],
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                softWrap: true,
                style: const TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: 18,
                    wordSpacing: 1.0),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              'You can Pay: ${widget.snapshot.data()['amount']}',
              style: TextStyle(color: Colors.green.shade700, fontSize: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () async {
                initiateTransaction(
                    apps![0],
                    widget.snapshot.data()['upi'],
                    widget.snapshot.data()['writer'],
                    widget.snapshot.data()['writer'],
                    "Some one pay you one New App",
                    widget.snapshot.data()['amount'] * 1.0);
              },
              child: Text(pay),
            ),
          )
        ],
      ),
    );
  }
}
