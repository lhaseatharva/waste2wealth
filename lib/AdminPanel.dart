import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste2wealth/LoginPage.dart';

class AdminPanel extends StatefulWidget {
  final String adminEmail;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AdminPanel({required this.adminEmail});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.deepOrange,
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
                    widget.adminEmail,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: FunctionalitySquare(
                        title: 'Manage Pickup Schedules',
                        icon: Icons.schedule,
                        onPressed: () {},
                        border:
                            Border.all(color: Colors.deepOrange, width: 2.0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: FunctionalitySquare(
                        title: 'Waste Collection Management',
                        icon: Icons.delete,
                        onPressed: () {},
                        border:
                            Border.all(color: Colors.deepOrange, width: 2.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: FunctionalitySquare(
                        title: 'Compost Management',
                        icon: Icons.eco,
                        onPressed: () {},
                        border:
                            Border.all(color: Colors.deepOrange, width: 2.0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: FunctionalitySquare(
                        title: 'Compost Selling',
                        icon: Icons.shop,
                        onPressed: () {},
                        border:
                            Border.all(color: Colors.deepOrange, width: 2.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                _logOut();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(), // Navigate to your login page
        ),
      );
    } catch (e) {
      print('Error during log out: $e');
    }
  }
}

class FunctionalitySquare extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Border border;

  FunctionalitySquare({
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: Colors.deepOrange,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
