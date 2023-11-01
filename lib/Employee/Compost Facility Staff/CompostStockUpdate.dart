import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompostStockUpdate extends StatefulWidget {
  @override
  _CompostStockUpdateState createState() => _CompostStockUpdateState();
}

class _CompostStockUpdateState extends State<CompostStockUpdate> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compost Stock Management'),
        backgroundColor: Colors.deepOrange, // Customize the app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Type of Compost:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                hintText: 'Enter compost type',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Quantity (kg):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter quantity in kg',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Price per kg:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter price per kg',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addStockToFirebase();
              },
              child: Text(
                'Add Stock',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                primary:
                    Colors.deepOrange.shade200, // Customize the button color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addStockToFirebase() {
    final String compostType = typeController.text.trim();
    final double quantity = double.tryParse(quantityController.text) ?? 0.0;
    final double pricePerKg = double.tryParse(priceController.text) ?? 0.0;

    if (compostType.isNotEmpty && quantity > 0 && pricePerKg > 0) {
      // Assuming you have initialized Firestore and have a reference to the collection.
      CollectionReference compostStock =
          FirebaseFirestore.instance.collection('compost_stock');

      compostStock.doc(compostType).get().then((docSnapshot) {
        if (docSnapshot.exists) {
          // Update the existing document.
          docSnapshot.reference.update({
            'quantity': FieldValue.increment(quantity),
            'pricePerKg': pricePerKg,
            'timestamp': FieldValue.serverTimestamp(),
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stock updated successfully!'),
              ),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating stock: $error'),
              ),
            );
          });
        } else {
          // Create a new document if it doesn't exist.
          compostStock.doc(compostType).set({
            'quantity': quantity,
            'pricePerKg': pricePerKg,
            'timestamp': FieldValue.serverTimestamp(),
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stock added successfully!'),
              ),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error adding stock: $error'),
              ),
            );
          });
        }

        // Clear the input fields after adding/updating the stock.
        typeController.clear();
        quantityController.clear();
        priceController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please provide valid compost type, quantity, and price.'),
        ),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: CompostStockUpdate(),
  ));
}
