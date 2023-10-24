import 'package:flutter/material.dart';
import 'package:waste2wealth/Employee/Pickup%20Staff/ManageSchedule.dart';

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
              leading: Icon(Icons.calendar_today),
              title: Text('Manage Schedule'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ManageSchedule(userEmail: widget.userEmail),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Check Requests'),
              onTap: () {
                // Add logic to navigate to the Check Requests screen
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
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
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
