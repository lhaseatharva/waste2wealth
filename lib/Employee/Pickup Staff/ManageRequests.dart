import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ManageRequests extends StatefulWidget {
  @override
  _ManageRequestsState createState() => _ManageRequestsState();
}

class _ManageRequestsState extends State<ManageRequests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userEmail = '';
  String userArea = ''; // Store the user's selected area
  String currentDay = '';
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _fetchCurrentDay();
    await _fetchUserArea();
    await _fetchMatchingRequests();
  }

  Future<void> _fetchUserArea() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userEmail = user.email;
      final dayOfWeek = DateFormat('EEEE').format(DateTime.now());
      final userDoc =
          await _firestore.collection('pickup_schedule').doc(userEmail).get();
      if (userDoc.exists) {
        final scheduleData = userDoc.data();
        final area = scheduleData?[dayOfWeek] as String;
        if (area.isNotEmpty) {
          print('User area for $dayOfWeek: $area');
          setState(() {
            userArea = area;
          });
        }
      }
    }
  }

  void _fetchCurrentDay() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE');
    currentDay = formatter.format(now);
    print('Current day: $currentDay');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Manage Requests'),
      ),
      body: requests.isEmpty
          ? Center(
              child: Text('No pickup requests for your area on $currentDay'))
          : ListView(
              children: requests.map((request) {
                return RequestCard(
                  request: request,
                  onDelete: () {
                    _deleteRequest(request);
                  },
                  onMarkAsComplete: () {
                    _markAsComplete(request);
                  },
                );
              }).toList(),
            ),
    );
  }

  Future<void> _fetchMatchingRequests() async {
    if (userArea.isEmpty || currentDay.isEmpty) {
      return;
    }

    print('Fetching requests for $userArea on $currentDay');

    final querySnapshot = await _firestore
        .collection('pickup_requests')
        .where('area', isEqualTo: userArea)
        .where('daysOfWeek.$currentDay', isEqualTo: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        requests = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
      print('Fetched ${requests.length} requests');
    }
  }

  void _markAsComplete(Map<String, dynamic> request) async {
    final documentId = request['documentID'];

    final updateData = {
      'daysOfWeek.$currentDay': false,
      'status.$currentDay': 'Complete',
    };

    try {
      await _firestore
          .collection('pickup_requests')
          .doc(documentId)
          .update(updateData);
    } catch (e) {
      print('Error marking as complete: $e');
    }

    await _fetchMatchingRequests();
  }

  void _deleteRequest(Map<String, dynamic> request) async {
    final documentId = request['documentID'];

    try {
      await _firestore.collection('pickup_requests').doc(documentId).delete();
    } catch (e) {
      print('Error deleting request: $e');
    }

    await _fetchMatchingRequests();
  }
}

class RequestCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsComplete;

  RequestCard({
    required this.request,
    required this.onDelete,
    required this.onMarkAsComplete,
  });

  @override
  _RequestCardState createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.request['restaurantName']),
            subtitle: Text('Area: ${widget.request['area']}'),
            trailing: IconButton(
              icon: Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Contact Person: ${widget.request['contactPerson']}'),
                  Text('Contact Number: ${widget.request['contactNumber']}'),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: widget.onMarkAsComplete,
                          child: Text('Mark as Complete'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.deepOrange.shade300),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: widget.onDelete,
                          child: Text('Delete'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.deepOrange.shade300),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
