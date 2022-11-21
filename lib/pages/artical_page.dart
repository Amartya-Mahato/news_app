import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

class ArticalPage extends StatefulWidget {
  const ArticalPage({super.key, required this.docs});

  final Map<String, dynamic> docs;

  @override
  State<ArticalPage> createState() => _ArticalPageState();
}

class _ArticalPageState extends State<ArticalPage> {
  UpiIndia _upiIndia = UpiIndia();
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
                color: Colors.grey,
                image: DecorationImage(
                    image: Image.network(
                      widget.docs['image'],
                    ).image,
                    fit: BoxFit.fill),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.docs['title'],
              style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Text('Writer: ${widget.docs['writer']}'),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.docs['discription'],
              overflow: TextOverflow.fade,
              softWrap: true,
              // maxLines: 20,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          // const Spacer(),
          Container(
            padding: const EdgeInsets.only(bottom: 8.0),
            alignment: Alignment.center,
            child: Text(
              'Actual price: ${widget.docs['fee']}',
              style: const TextStyle(color: Colors.red, fontSize: 15),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              'Discounted price: ${widget.docs['discount_fee']}',
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () async {
                initiateTransaction(
                    apps![0],
                    widget.docs['upi'],
                    widget.docs['writer'],
                    widget.docs['writer'],
                    "this is the payment from your app",
                    widget.docs['discount_fee'] * 1.0);
              },
              child: Text(pay),
            ),
          )
        ],
      ),
    );
  }
}
