import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Restaurant';
  bool _registrationSuccess = false;

  void _handleRoleChange(String value) {
    setState(() {
      _selectedRole = value;
    });
  }

  // Generate a unique userid
  String _generateUniqueUserId() {
    final String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    final String userId = String.fromCharCodes(Iterable.generate(
        12, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    return userId;
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Success'),
          content: Text(
              'You are successfully registered under the category: $_selectedRole'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Registration Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CarouselSlider(
                items: [
                  Image.asset('assets/images/carousel/image_1.jpg'),
                  Image.asset('assets/images/carousel/image_2.jpg'),
                  Image.asset('assets/images/carousel/image_3.jpg'),
                  Image.asset('assets/images/carousel/image_4.jpg'),
                ],
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 2.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Select User Type:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                items: <String>['Restaurant', 'Employee', 'Buyer']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email ID',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.deepOrange,
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    UserCredential userCredential =
                        await _auth.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    // Generate a unique userid
                    String userId = _generateUniqueUserId();

                    // Save user details under "Users" collection
                    await _firestore.collection('Users').doc(userId).set({
                      'email': _emailController.text,
                      'role': _selectedRole,
                      'userid': userId,
                      'isAdmin': false, // Add isAdmin field and set it to false
                      // Add additional user data as needed
                    });

                    setState(() {
                      _registrationSuccess = true;
                    });

                    _showRegistrationSuccessDialog();
                  } catch (e) {
                    print('Error during registration: $e');
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.deepOrange.shade200),
                ),
                child: Text('Register'),
              ),
              if (_registrationSuccess)
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the login screen
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.deepOrange.shade200),
                  ),
                  child: Text('Go to Login'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
