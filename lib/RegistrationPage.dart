import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Employee';
  String _selectedSubCategory = 'Pickup Staff';
  bool _registrationSuccess = false;
  final _formKey = GlobalKey<FormState>();

  List<String> carouselImages = [
    'assets/images/carousel/image_1.jpg',
    'assets/images/carousel/image_2.jpg',
    'assets/images/carousel/image_3.jpg',
    'assets/images/carousel/image_4.jpg',
  ];

  void _handleRoleChange(String value) {
    setState(() {
      _selectedRole = value;
    });
  }

  void _handleSubCategoryChange(String value) {
    setState(() {
      _selectedSubCategory = value;
    });
  }

  Future<void> _showRegistrationSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Success'),
          content: Text(
              'You are successfully registered under the category: $_selectedRole as $_selectedSubCategory'),
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

  String _generateUniqueUserId() {
    final String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    final String userId = String.fromCharCodes(Iterable.generate(
        12, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    return userId;
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
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                CarouselSlider(
                  items: carouselImages.map((imagePath) {
                    return Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
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
                if (_selectedRole == 'Employee')
                  DropdownButton<String>(
                    value: _selectedSubCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSubCategory = newValue!;
                      });
                    },
                    items: <String>['Pickup Staff', 'Compost Facility Staff']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(
                        Icons.lock,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        UserCredential userCredential =
                            await _auth.createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        String userId = _generateUniqueUserId();

                        await _firestore.collection('Users').doc(userId).set({
                          'email': _emailController.text,
                          'role': _selectedRole,
                          'subCategory': _selectedSubCategory,
                          'userid': userId,
                          'isAdmin': false,
                        });

                        setState(() {
                          _registrationSuccess = true;
                        });

                        await _showRegistrationSuccessDialog();
                      } catch (e) {
                        print('Error during registration: $e');
                      }
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
      ),
    );
  }
}
