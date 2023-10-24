import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class RestaurantDashboard extends StatefulWidget {
  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _restaurantNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _contactPersonController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();

  String _pickupFrequency = 'Daily'; // Default value
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Restaurant Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Add Pickup Request',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _restaurantNameController,
                decoration: InputDecoration(
                  labelText: 'Restaurant Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter restaurant name';
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactPersonController,
                decoration: InputDecoration(
                  labelText: 'Contact Person',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact person';
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Select Pickup Frequency:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Center(
                child: DropdownButton<String>(
                  value: _pickupFrequency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _pickupFrequency = newValue!;
                    });
                  },
                  items: <String>['Daily', 'Weekly', 'Bi-Weekly', 'Tri-Weekly']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Spacer(), // Create space below the Dropdown
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isSubmitting = true;
                          });
                          await _submitRequest();
                          setState(() {
                            _isSubmitting = false;
                          });
                        }
                      },
                child: _isSubmitting
                    ? CircularProgressIndicator()
                    : Text('Submit Request'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.deepOrange.shade200),
                  minimumSize: MaterialStateProperty.all(
                    Size(double.infinity, 48.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    String restaurantName = _restaurantNameController.text;
    String address = _addressController.text;
    String contactPerson = _contactPersonController.text;
    String contactNumber = _contactNumberController.text;
    String pickupFrequency = _pickupFrequency;
    String status = 'Pending';

    // Get the current day of the week
    String dayOfWeek = DateFormat('EEEE').format(DateTime.now());

    // Generate a new unique request ID
    String requestId = _generateRequestId();

    await _firestore.collection('pickup_requests').doc(requestId).set({
      'restaurantName': restaurantName,
      'address': address,
      'contactPerson': contactPerson,
      'contactNumber': contactNumber,
      'pickupFrequency': pickupFrequency,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'dayOfWeek': dayOfWeek, // Store the day of the week
    });

    // Clear the input fields
    _restaurantNameController.clear();
    _addressController.clear();
    _contactPersonController.clear();
    _contactNumberController.clear();

    // Show confirmation dialog
    _showConfirmationDialog();
  }

  String _generateRequestId() {
    // Generate a random alphanumeric string of length 10 for the Request ID
    final Random _random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(10, (index) => chars[_random.nextInt(chars.length)])
        .join();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Submitted'),
          content: Text('Your request is submitted successfully. '
              'Please be patient while we process your request.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RestaurantDashboard(),
  ));
}
