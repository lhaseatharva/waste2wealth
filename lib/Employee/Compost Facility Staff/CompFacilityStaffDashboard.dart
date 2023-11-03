import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste2wealth/Employee/Compost%20Facility%20Staff/AllocateBinsScreen.dart';
import 'package:waste2wealth/Employee/Compost%20Facility%20Staff/CompostStatusPage.dart';
import 'package:waste2wealth/Employee/Compost%20Facility%20Staff/CompostStockUpdate.dart';
import 'package:waste2wealth/Employee/Compost%20Facility%20Staff/ManageWasteScreen.dart';
import 'package:waste2wealth/LoginPage.dart';

class CompFacilityStaffDashboard extends StatefulWidget {
  @override
  _CompFacilityStaffDashboardState createState() =>
      _CompFacilityStaffDashboardState();
}

class _CompFacilityStaffDashboardState
    extends State<CompFacilityStaffDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Log Out'),
              onPressed: () {
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compost Facility Management'),
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
                    userEmail,
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
              leading: Icon(Icons.exit_to_app),
              onTap: () {
                _showLogoutConfirmationDialog();
              },
            ),
          ],
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 3.0,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(16),
            child: InkWell(
              onTap: () => _handleButtonTap(index, context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _getButtonIcon(index),
                  SizedBox(height: 8),
                  Text(
                    _getButtonLabel(index),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleButtonTap(int index, BuildContext context) {
    if (index == 0) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ManageWasteScreen(),
      ));
    }
    if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AllocateBinsScreen(),
      ));
    }
    if (index == 2) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CompostStatusPage(),
      ));
    }
    if (index == 3) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CompostStockUpdate(),
      ));
    }
  }

  String _getButtonLabel(int index) {
    switch (index) {
      case 0:
        return 'Manage Waste';
      case 1:
        return 'Allocate Bins to Waste';
      case 2:
        return 'Supervise Compost Manufacturing';
      case 3:
        return 'Update Compost Stock';
      default:
        return '';
    }
  }

  Widget _getButtonIcon(int index) {
    String imageUrl = '';

    switch (index) {
      case 0:
        imageUrl = 'https://cdn-icons-png.flaticon.com/128/10205/10205395.png';
        break;
      case 1:
        imageUrl = 'https://cdn-icons-png.flaticon.com/128/4660/4660787.png';
        break;
      case 2:
        imageUrl = 'https://cdn-icons-png.flaticon.com/128/2622/2622171.png';
        break;
      case 3:
        imageUrl = 'https://cdn-icons-png.flaticon.com/128/2897/2897785.png';
        break;
    }

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 64,
        height: 64,
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: CompFacilityStaffDashboard(),
  ));
}
