import 'package:flutter/material.dart';
import 'package:waste2wealth/LoginPage.dart';
import 'package:waste2wealth/RegistrationPage.dart';
import 'package:waste2wealth/RestaurantDashboard.dart'; // Import the Restaurant Dashboard page

void main() {
  runApp(MaterialApp(
    home: WelcomePage(),
  ));
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color is black
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/compost.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'waste2wealth',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RestaurantDashboard()), // Navigate to RestaurantDashboard
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: EdgeInsets.all(20.0),
                  minimumSize: Size(300, 0),
                ),
                child: Text(
                  'Schedule Pickup', // Change button text to "Schedule Pickup"
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: EdgeInsets.all(20.0),
                  minimumSize: Size(300, 0),
                ),
                child: Text(
                  'Login Here',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: EdgeInsets.all(20.0),
                  minimumSize: Size(300, 0),
                ),
                child: Text(
                  'Register Here',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
