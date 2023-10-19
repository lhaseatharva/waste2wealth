import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/AdminPanel.dart';
import 'package:waste2wealth/EmployeeDashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Employee'; // Default value

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

  Future<bool> _loginAndCheckAdmin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (_selectedRole == 'Admin') {
        // Check if the user is an admin
        bool isAdmin = await _checkAdminStatus(userCredential.user!.email!);
        return isAdmin;
      }
      return true; // For other roles (Employee, Buyer)
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<bool> _checkAdminStatus(String email) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final isAdmin = querySnapshot.docs.first['isAdmin'];
        return isAdmin == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  Future<void> _handleLogin() async {
    bool isAdmin = await _loginAndCheckAdmin();

    if (isAdmin) {
      if (_selectedRole == 'Admin') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AdminPanel(adminEmail: _emailController.text)));
        _showSuccessDialog(); // Show success dialog
      } else if (_selectedRole == 'Employee') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => EmployeeDashboard()));
        _showSuccessDialog(); // Show success dialog
      } else if (_selectedRole == 'Buyer') {
        // Redirect to Buyer-specific page (add your logic here)
        _showSuccessDialog(); // Show success dialog
      }
    } else {
      _showCategoryMismatchDialog(); // Show category mismatch dialog
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Success'),
          content: Text(
              'Successfully Logged in under the category : $_selectedRole'),
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

  void _showCategoryMismatchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Category Mismatch'),
          content:
              Text('No matching account found for the provided credentials.'),
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
        title: Text('Login Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
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
              Text(
                'Select User Type',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Center(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: <String>['Employee', 'Buyer', 'Admin']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email,
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
                    prefixIcon: Icon(
                      Icons.lock,
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text('Login'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.deepOrange.shade200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
