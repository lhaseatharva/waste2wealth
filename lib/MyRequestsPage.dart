import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRequestsPage extends StatefulWidget {
  @override
  _MyRequestsPageState createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  int _currentIndex = 0;

  Widget _buildRequestsPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pickup_requests')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('status',
              isEqualTo: _currentIndex == 0 ? 'Pending' : 'Completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        List<Widget> requestWidgets = [];
        for (var request in requests) {
          final restaurantName = request['restaurantName'];
          final address = request['address'];
          final quantity = request['quantity'];

          final requestWidget = ListTile(
            title: Text('Restaurant: $restaurantName'),
            subtitle: Text('Address: $address\nQuantity: $quantity'),
          );

          requestWidgets.add(requestWidget);
        }

        return ListView(
          children: requestWidgets,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Requests'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _buildRequestsPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions_rounded),
            label: "Pending Requests",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: "Completed Requests",
          ),
        ],
      ),
    );
  }
}
