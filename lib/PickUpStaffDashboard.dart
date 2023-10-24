import 'package:flutter/material.dart';

class PickUpStaffDashboard extends StatefulWidget {
  final String userEmail;

  PickUpStaffDashboard({required this.userEmail});

  @override
  _PickUpStaffDashboardState createState() => _PickUpStaffDashboardState();
}

class _PickUpStaffDashboardState extends State<PickUpStaffDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Pickup Staff Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add logic to handle notifications
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.deepOrange,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.userEmail,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Set Schedule'),
              onTap: () {
                // Add logic to navigate to the Set Schedule screen
              },
            ),
            ListTile(
              title: Text('Check Requests'),
              onTap: () {
                // Add logic to navigate to the Check Requests screen
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                _showLogoutConfirmationDialog();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to Pickup Staff Dashboard'),
      ),
    );
  }

  // Function to display the logout confirmation dialog
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Do you really want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add logic to perform logout
                // For example, navigate to the login screen
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
