import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste2wealth/Admin/CompostBinManagement.dart';
import 'package:waste2wealth/Admin/ManagePickupSchedule.dart';
import 'package:waste2wealth/Admin/WasteStockManagement.dart';
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
            UserAccountsDrawerHeader(
              accountName: Text('Admin'),
              accountEmail: Text(widget.adminEmail),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.deepOrange,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
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
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          FunctionalitySquare(
            title: 'Manage Pickup Schedule',
            icon: Icons.calendar_today,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManagePickupSchedule(),
                ),
              );
            },
          ),
          FunctionalitySquare(
            title: 'Waste Stock Management',
            icon: Icons.delete,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WasteStockManagement(),
                ),
              );
            },
          ),
          FunctionalitySquare(
            title: 'Compost Management',
            icon: Icons.eco,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompostBinManagement(),
                ),
              );
              // Add your logic for Compost Management here
            },
          ),
          FunctionalitySquare(
            title: 'Compost Selling',
            icon: Icons.shop,
            onTap: () {
              // Add your logic for Compost Selling here
            },
          ),
        ],
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
          builder: (context) => LoginPage(),
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
  final VoidCallback onTap;

  FunctionalitySquare({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
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
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
