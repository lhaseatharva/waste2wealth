import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math';

class RestaurantDashboard extends StatefulWidget {
  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _restaurantNameController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _contactPersonController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();

  Map<String, bool> selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
  };

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
                controller: _areaController,
                decoration: InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter area';
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
              ExpansionTile(
                title: Text(
                  'Select Days of Pickup:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: [
                  Column(
                    children: selectedDays.keys.map((day) {
                      return CheckboxListTile(
                        title: Text(day),
                        value: selectedDays[day],
                        onChanged: (value) {
                          setState(() {
                            selectedDays[day] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              Spacer(),
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
                    ? SpinKitCircle(
                        color: Colors.white,
                        size: 20.0,
                      )
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
    String area = _areaController.text;
    String contactPerson = _contactPersonController.text;
    String contactNumber = _contactNumberController.text;

    String requestId = _generateRequestId();

    Map<String, String> status = {};
    selectedDays.forEach((day, isSelected) {
      if (isSelected) {
        status[day] = 'Pending';
      } else {
        status[day] = '-';
      }
    });

    Map<String, bool> daysOfWeek = Map.from(selectedDays);

    await _firestore.collection('pickup_requests').doc(requestId).set({
      'restaurantName': restaurantName,
      'area': area,
      'contactPerson': contactPerson,
      'contactNumber': contactNumber,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status,
      'daysOfWeek': daysOfWeek,
      'documentID': requestId,
    });

    _restaurantNameController.clear();
    _areaController.clear();
    _contactPersonController.clear();
    _contactNumberController.clear();
    setState(() {
      selectedDays = selectedDays.map((day, value) => MapEntry(day, false));
    });

    _showConfirmationDialog();
  }

  String _generateRequestId() {
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

void main() {
  runApp(MaterialApp(
    home: RestaurantDashboard(),
  ));
}
