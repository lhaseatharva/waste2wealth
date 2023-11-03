import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/Admin/AdminPanel.dart';
import 'package:waste2wealth/Buyer/BuyerDashboard.dart';
import 'package:waste2wealth/Employee/Compost%20Facility%20Staff/CompFacilityStaffDashboard.dart';
import 'package:waste2wealth/Employee/Pickup%20Staff/PickUpStaffDashboard.dart';
import 'package:waste2wealth/WelcomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Employee'; // Default value
  String _selectedSubCategory = 'Pickup Staff'; // Default value

  List<String> carouselImages = [
    'assets/images/carousel/image_1.jpg',
    'assets/images/carousel/image_2.jpg',
    'assets/images/carousel/image_3.jpg',
    'assets/images/carousel/image_4.jpg',
  ];

  void _handleRoleChange(String value) {
    setState(() {
      _selectedRole = value;
      _selectedSubCategory = 'Pickup Staff';
    });
  }

  void _handleSubCategoryChange(String value) {
    setState(() {
      _selectedSubCategory = value;
    });
  }

  Future<void> _handleLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (_selectedRole == 'Admin') {
        // Check if the user is an admin
        bool isAdmin = await _checkAdminStatus(userCredential.user!.email!);
        if (isAdmin) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AdminPanel(adminEmail: _emailController.text)));
          _showSuccessDialog('Admin'); // Show success dialog for admin
        } else {
          _showLoginErrorDialog(); // Show login error dialog
        }
      } else if (_selectedRole == 'Employee') {
        if (_selectedSubCategory == 'Pickup Staff') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PickUpStaffDashboard(userEmail: _emailController.text)));
          _showSuccessDialog(
              'Pickup Staff'); // Show success dialog for Pickup Staff
        } else if (_selectedSubCategory == 'Compost Facility Staff') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => CompFacilityStaffDashboard()));
          _showSuccessDialog(
              'Compost Facility Staff'); // Show success dialog for Compost Facility Staff
        } else {
          _showLoginErrorDialog(); // Show login error dialog
        }
      } else if (_selectedRole == 'Buyer') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BuyerDashboard()));
        _showSuccessDialog('Buyer'); // Show success dialog for Buyer
      } else {
        _showLoginErrorDialog(); // Show login error dialog
      }
    } catch (e) {
      print('Error during login: $e');
      _showLoginErrorDialog(); // Show login error dialog
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

  void _showSuccessDialog(String userType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Success'),
          content: Text(
              'Successfully logged in as a $userType under the category: $_selectedRole'),
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

  void _showLoginErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text('An error occurred during login.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text('Login Page'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WelcomePage(),
                ),
              );
            },
          ),
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
                      _handleRoleChange(newValue!);
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
                if (_selectedRole == 'Employee')
                  Center(
                    child: DropdownButton<String>(
                      value: _selectedSubCategory,
                      onChanged: (String? newValue) {
                        _handleSubCategoryChange(newValue!);
                      },
                      items: <String>['Pickup Staff', 'Compost Facility Staff']
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
      ),
    );
  }
}
