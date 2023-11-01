import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompostStatusPage extends StatefulWidget {
  @override
  _CompostStatusPageState createState() => _CompostStatusPageState();
}

class _CompostStatusPageState extends State<CompostStatusPage> {
  String selectedBin = '';
  List<String> binNames = [];
  String filledIn = '';
  String completedOn = '';
  double maxQty = 0; // Change to double
  double currQty = 0; // Change to double

  @override
  void initState() {
    super.initState();
    fetchBinData();
  }

  Future<void> fetchBinData() async {
    // Assuming you have initialized Firestore and have a reference to the collection.
    CollectionReference compostBins =
        FirebaseFirestore.instance.collection('compost_bins');

    QuerySnapshot binSnapshot = await compostBins.get();
    setState(() {
      binNames = binSnapshot.docs.map((doc) => doc.id).toList();
      // Initially select the first bin.
      selectedBin = (binNames.isNotEmpty ? binNames[0] : null)!;
    });
  }

  Future<void> showBinStatus(String binName) async {
    final binDocument = await FirebaseFirestore.instance
        .collection('compost_bins')
        .doc(binName)
        .get();

    if (binDocument.exists) {
      final binData = binDocument.data() as Map<String, dynamic>;

      if (binData.containsKey('waste') &&
          binData['waste'].containsKey(binName)) {
        final binWaste = binData['waste'][binName];
        if (binWaste is Map<String, dynamic>) {
          if (binWaste.containsKey('filledIn') &&
              binWaste.containsKey('completedOn')) {
            filledIn = binWaste['filledIn'];
            completedOn = binWaste['completedOn'];
          }
        }
      }

      if (binData.containsKey('maxQty') && binData.containsKey('currQty')) {
        maxQty = (binData['maxQty'] as num).toDouble(); // Convert to double
        currQty = (binData['currQty'] as num).toDouble(); // Convert to double
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Status for $binName'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (filledIn.isNotEmpty) Text('Filled In: $filledIn'),
                if (completedOn.isNotEmpty) Text('Completed On: $completedOn'),
                Text('Maximum Quantity: $maxQty'),
                Text('Current Quantity: $currQty'),
                // You can display more fields here if needed.
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Compost Status'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: selectedBin,
              items: binNames.map((binName) {
                return DropdownMenuItem<String>(
                  value: binName,
                  child: Text(binName),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedBin = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade200),
              onPressed: () {
                // Display the bin status in a popup.
                showBinStatus(selectedBin);
              },
              child: Text("Check Status"),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: CompostStatusPage(),
    ));
