import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllocateBinsScreen extends StatefulWidget {
  @override
  _AllocateBinsScreenState createState() => _AllocateBinsScreenState();
}

class _AllocateBinsScreenState extends State<AllocateBinsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> binNames = [
    'Bin 1',
    'Bin 2',
    'Bin 3',
  ]; // Add more bin names as needed
  String selectedBin = 'Bin 1';
  double compostableWaste = 0.0; // Change the data type to double
  bool isAllocating = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Compost Bins Management'),
      ),
      body: Column(
        children: <Widget>[
          // Display compostable waste
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('waste_stock').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                double totalWaste = 0.0;
                for (var doc in snapshot.data!.docs) {
                  totalWaste += doc['weight'];
                }
                compostableWaste = totalWaste;
              }
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Compostable Waste: $compostableWaste kg'),
              );
            },
          ),

          // Bin selection dropdown
          Padding(
            padding: EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedBin,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedBin = newValue;
                  });
                }
              },
              items: binNames.map((String binName) {
                return DropdownMenuItem<String>(
                  value: binName,
                  child: Text(binName),
                );
              }).toList(),
            ),
          ),

          // Allocate button
          ElevatedButton(
            onPressed: () {
              // Handle the allocation here
              _allocateBin();
            },
            child: Text('Allocate'),
          ),

          // Circular Progress Indicator
          if (isAllocating)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // Function to allocate a bin
  void _allocateBin() {
    setState(() {
      isAllocating = true;
    });

    if (compostableWaste > 0) {
      // Find today's date in the format 'YYYY-MM-DD'
      String todayDate = DateTime.now().toLocal().toString().split(' ')[0];

      // Update Firestore with the allocated bin and update currQty in compost_bins collection
      _firestore
          .collection('compost_bins')
          .doc(selectedBin)
          .get()
          .then((binDoc) {
        if (binDoc.exists) {
          double currQty = binDoc.data()!['currQty'] + compostableWaste;

          _firestore.collection('compost_bins').doc(selectedBin).update({
            'currQty': currQty,
          });

          // Delete the waste_stock document corresponding to the selected bin
          _firestore
              .collection('waste_stock')
              .where('collectedOn',
                  isEqualTo: todayDate) // Match based on today's date
              .get()
              .then((querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              doc.reference.delete();
            });

            // Show a SnackBar with a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Allocation successful'),
                duration: Duration(seconds: 2),
              ),
            );

            setState(() {
              isAllocating = false;
            });
          });
        } else {
          // Show a SnackBar with an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected bin not found'),
              duration: Duration(seconds: 2),
            ),
          );

          setState(() {
            isAllocating = false;
          });
        }
      });
    } else {
      setState(() {
        isAllocating = false;
      });

      // Show a SnackBar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No waste to allocate'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
