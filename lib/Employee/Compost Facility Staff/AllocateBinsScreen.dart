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
    'Bin 3'
  ]; // Add more bin names as needed
  String selectedBin = 'Bin 1';
  num compostableWaste = 0.0;

  @override
  void initState() {
    super.initState();
    // Fetch the compostableWaste value from the Firestore waste_stock collection's weight field
    _fetchCompostableWaste();
  }

  // Function to fetch compostableWaste from Firestore
  void _fetchCompostableWaste() {
    // Replace 'restaurantName' with the actual name or identifier of the restaurant
    _firestore
        .collection('waste_stock')
        .doc('restaurantName') // Use the restaurant name as the document ID
        .get()
        .then((doc) {
      if (doc.exists) {
        // Check if the document exists
        setState(() {
          compostableWaste = doc.data()!['weight'];
        });
      }
    });
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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Compostable Waste: $compostableWaste kg'),
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
        ],
      ),
    );
  }

  // Function to allocate a bin
  void _allocateBin() {
    if (compostableWaste > 0) {
      // Update Firestore with the allocated bin and update currQty in compost_bins collection
      _firestore.collection('compost_bins').doc(selectedBin).update({
        'currQty': FieldValue.increment(compostableWaste),
      });

      // Delete the waste_stock document
      // Replace 'restaurantName' with the actual name or identifier of the restaurant
      _firestore.collection('waste_stock').doc('restaurantName').delete();

      // Go back to the previous screen
      Navigator.of(context).pop();
    } else {
      // Show an error message or dialog if compostableWaste is not greater than 0.
      // You can handle this based on your application's requirements.
    }
  }
}
