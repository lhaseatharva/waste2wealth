import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/ManageStockPage.dart';

class EmployeeDashboard extends StatefulWidget {
  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? selectedVolunteer;
  List<String> volunteers = []; // List to store volunteer names
  Map<String, String?> requestVolunteerMap =
      {}; // Map to store request-volunteer associations

  @override
  void initState() {
    super.initState();
    // Fetch volunteers and request-volunteer associations from Firestore when the widget initializes
    _fetchVolunteers();
  }

  Future<void> _fetchVolunteers() async {
    final volunteersCollection =
        FirebaseFirestore.instance.collection('volunteers');
    final querySnapshot = await volunteersCollection.get();
    final volunteerNames =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    setState(() {
      volunteers = volunteerNames;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final userEmail = user != null ? user.email! : "";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Employee Dashboard'),
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
              title: Text('Manage Stock'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageStockPage(),
                  ),
                );
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
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Requests Section',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child:
                    _buildRequestsList(), // Use a function to build the requests list
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pickup_requests')
          .where('status', isEqualTo: 'Pending') // Fetch all pending requests
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final requests = snapshot.data!.docs;

        return Column(
          children: <Widget>[
            for (var request in requests) _buildRequestCard(request),
          ],
        );
      },
    );
  }

  Widget _buildRequestCard(DocumentSnapshot request) {
    final restaurantName = request['restaurantName'] as String? ?? '';
    final contactPerson = request['contactPerson'] as String? ?? '';
    final contactNumber = request['contactNumber'] as String? ?? '';
    final address = request['address'] as String? ?? '';
    final requestId = request.id; // Get the document ID
    final requestVolunteer = requestVolunteerMap[requestId] ?? null;

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(
            title: Text('Restaurant Name: $restaurantName'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact Person: $contactPerson'),
                Text('Contact Number: $contactNumber'),
                Text('Address: $address'),
              ],
            ),
          ),
          _buildFulfillButton(requestId, requestVolunteer),
        ],
      ),
    );
  }

  Widget _buildFulfillButton(String requestId, String? requestVolunteer) {
    final availableVolunteers = volunteers
        .where((volunteer) =>
            requestVolunteerMap.containsValue(volunteer) ||
            volunteer != requestVolunteer) // Include selected volunteer
        .toList();

    return Row(
      children: [
        SizedBox(width: 16),
        DropdownButton<String>(
          value: requestVolunteer,
          items: availableVolunteers
              .map((volunteer) => DropdownMenuItem(
                    value: volunteer,
                    child: Text(volunteer),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              // Update the request-volunteer association
              requestVolunteerMap[requestId] = value;
            });
          },
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: requestVolunteer != null
              ? () => _fulfillRequest(requestId, requestVolunteer)
              : null,
          child: Text('Approve'),
          style: ElevatedButton.styleFrom(
            primary: Colors.deepOrange, // Set button color to DeepOrange
          ),
        ),
      ],
    );
  }

  void _fulfillRequest(String requestId, String? requestVolunteer) async {
    if (requestVolunteer != null) {
      try {
        // Update the request status to Completed
        await FirebaseFirestore.instance
            .collection('pickup_requests')
            .doc(requestId)
            .update({
          'status': 'Completed',
        });

        // Update the volunteer's isAvail field to false
        await FirebaseFirestore.instance
            .collection('volunteers')
            .where('name', isEqualTo: requestVolunteer)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final volunteerDocRef = querySnapshot.docs.first.reference;
            volunteerDocRef.update({
              'isAvail': false,
            });
          }
        });

        // Remove the request from the list
        setState(() {
          requestVolunteerMap.remove(requestId);
        });

        // Display a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request Approved'),
          ),
        );
      } catch (e) {
        // Handle errors, if any
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Request approval failed'),
          ),
        );
      }
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}

void main() {
  runApp(MaterialApp(
    home: EmployeeDashboard(),
  ));
}
