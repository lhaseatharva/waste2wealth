import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    home: BuyerDashboard(),
  ));
}

class BuyerDashboard extends StatefulWidget {
  @override
  _BuyerDashboardState createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _quantityController = TextEditingController();
  double ratePerKg = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRatePerKg(); // Fetch rate per kg from Firestore
  }

  Future<void> _loadRatePerKg() async {
    try {
      final rateDoc = await FirebaseFirestore.instance
          .collection('stock')
          .doc('stock_data')
          .get();

      if (rateDoc.exists) {
        final rateData = rateDoc.data() as Map<String, dynamic>;
        final rate = rateData['rate'] as num?;

        if (rate != null) {
          setState(() {
            ratePerKg = rate.toDouble();
          });
        }
      }
    } catch (error) {
      print('Error fetching rate: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Buyer Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Set the form key
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), // Add separation
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), // Add separation
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (in kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Calculate amount based on quantity and rate per kg
                  double quantity = double.tryParse(value) ?? 0.0;
                  double amount = quantity * ratePerKg; // Calculate amount
                  _quantityController.text = amount.toStringAsFixed(2);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), // Add separation
              TextFormField(
                controller: TextEditingController(
                  text: '₹ ${ratePerKg.toStringAsFixed(2)}',
                ), // Rate per kg as a label
                readOnly: true, // Make it non-editable
                decoration: InputDecoration(
                  labelText: 'Rate Per kg',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16), // Add separation
              ElevatedButton(
                onPressed: () {
                  // Check if the form is valid before displaying the confirmation dialog
                  if (_formKey.currentState!.validate()) {
                    _showConfirmationDialog();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Colors.deepOrange.shade200), // Button color
                ),
                child: Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Rate per kg: ₹ ${ratePerKg.toStringAsFixed(2)}'),
              Text('Amount to be paid: ₹ ${_quantityController.text}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitOrder(); // Handle order submission
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.deepOrange.shade200),
              ),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _submitOrder() async {
    // Prepare order data
    final orderData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'quantity': double.parse(_quantityController.text),
      'ratePerKg': ratePerKg,
      'amount': double.parse(_quantityController.text), // Amount as a double
    };

    try {
      // Add the order to the "orders" collection in Firestore
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Clear form fields
      _nameController.clear();
      _addressController.clear();
      _quantityController.clear();

      // Show a success message or navigate to a success screen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Order Placed'),
            content: Text('Your order has been successfully placed.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while placing the order.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
