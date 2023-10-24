import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MaterialApp(
    home: ManageRequests(),
  ));
}

class ManageRequests extends StatefulWidget {
  @override
  _ManageRequestsState createState() => _ManageRequestsState();
}

class _ManageRequestsState extends State<ManageRequests> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Request> requests = [];
  String currentDay = DateFormat('EEEE').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      final email = await fetchUserEmail();
      if (email != null) {
        final userSchedule = await fetchUserArea(email);
        if (userSchedule != null) {
          final querySnapshot = await firestore
              .collection('pickup_requests')
              .where('dayOfWeek', isEqualTo: currentDay)
              .where('area', isEqualTo: userSchedule.area)
              .get();

          final List<Request> fetchedRequests = querySnapshot.docs.map((doc) {
            return Request.fromMap(doc.data());
          }).toList();

          setState(() {
            requests = fetchedRequests;
          });
        }
      }
    } catch (error) {
      print('Error fetching requests: $error');
    }
  }

  Future<String?> fetchUserEmail() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        return user.email;
      } else {
        print('User not signed in');
        return null;
      }
    } catch (error) {
      print('Error fetching user email: $error');
      return null;
    }
  }

  Future<UserSchedule> fetchUserArea(String userEmail) async {
    try {
      final userScheduleDocument =
          await firestore.collection('pickup_schedule').doc(userEmail).get();

      if (userScheduleDocument.exists) {
        final userScheduleData =
            userScheduleDocument.data() as Map<String, dynamic>;
        return UserSchedule.fromMap(userScheduleData);
      } else {
        return UserSchedule(
            area:
                'Erandwane'); // Provide a default value when the schedule is not found
      }
    } catch (error) {
      print('Error fetching user area: $error');
      return UserSchedule(
          area: 'Kothrud'); // Provide a default value in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Requests'),
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return RequestCard(
            request: request,
          );
        },
      ),
    );
  }
}

class Request {
  final String day;
  final String area;
  final String restaurantName;
  final String contactPerson;

  Request({
    required this.day,
    required this.area,
    required this.restaurantName,
    required this.contactPerson,
  });

  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      day: map['dayOfWeek'],
      area: map['area'],
      restaurantName: map['restaurantName'],
      contactPerson: map['contactPerson'],
    );
  }
}

class UserSchedule {
  final String area;

  UserSchedule({
    required this.area,
  });

  factory UserSchedule.fromMap(Map<String, dynamic> map) {
    return UserSchedule(
      area: map['area'],
    );
  }
}

class RequestCard extends StatefulWidget {
  final Request request;

  RequestCard({
    required this.request,
  });

  @override
  _RequestCardState createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Restaurant Name: ${widget.request.restaurantName}'),
            subtitle: Text('Area: ${widget.request.area}'),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
          if (isExpanded)
            Column(
              children: [
                ListTile(
                  title:
                      Text('Contact Person: ${widget.request.contactPerson}'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
