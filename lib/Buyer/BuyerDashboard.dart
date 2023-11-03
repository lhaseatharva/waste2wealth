import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/LoginPage.dart';

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
  final _contactNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  final _totalBillController = TextEditingController();
  double ratePerKg = 0.0;
  String selectedCompostType = 'Vermicompost';
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadRatePerKg();
    _loadUserEmail();
    _totalBillController.text = '0.0';
  }

  Future<void> _loadRatePerKg() async {
    try {
      final rateDoc = await FirebaseFirestore.instance
          .collection('compost_stock')
          .doc(selectedCompostType)
          .get();

      if (rateDoc.exists) {
        final rateData = rateDoc.data() as Map<String, dynamic>;
        final rate = rateData['pricePerKg'] as num?;

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

  Future<void> _loadUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
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
              Text('Amount to be paid: ₹ ${_totalBillController.text}'),
              Text('Contact Number: ${_contactNumberController.text}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitOrder();
                Navigator.of(context).pop();
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
    final orderData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'typeOfCompost': selectedCompostType,
      'quantity': double.parse(_quantityController.text),
      'totalBill': double.parse(_totalBillController.text),
      'contactNumber': _contactNumberController.text,
    };

    try {
      await FirebaseFirestore.instance
          .collection('compost_orders')
          .add(orderData);

      await FirebaseFirestore.instance
          .collection('compost_stock')
          .doc(selectedCompostType)
          .update({
        'quantity':
            FieldValue.increment(-double.parse(_quantityController.text)),
      });

      _nameController.clear();
      _addressController.clear();
      _quantityController.clear();
      _contactNumberController.clear();
      _totalBillController.text = '0.0';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Buyer Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: userEmail != null ? Text(userEmail!) : null,
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person),
                backgroundColor: Colors.deepOrange,
              ),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              accountName: null,
            ),
            ListTile(
              title: Text('My Orders'),
              leading: Icon(Icons.shopping_cart),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Log Out'),
              leading: Icon(Icons.exit_to_app),
              onTap: _logOut,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
              SizedBox(height: 16),
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
              SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedCompostType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCompostType = newValue!;
                    _loadRatePerKg();
                  });
                },
                items: <String>['Vermicompost', 'Organic']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (in kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  double quantity = double.tryParse(value) ?? 0.0;
                  double amount = quantity * ratePerKg;
                  _totalBillController.text = amount.toStringAsFixed(2);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: TextEditingController(
                  text: '₹ ${ratePerKg.toStringAsFixed(2)}',
                ),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Rate Per kg',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _totalBillController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Total Bill',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showConfirmationDialog();
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.deepOrange.shade200),
                ),
                child: Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      print('Error during log out: $e');
    }
  }
}
