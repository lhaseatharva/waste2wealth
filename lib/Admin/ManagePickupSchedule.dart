import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePickupSchedule extends StatefulWidget {
  @override
  _ManagePickupScheduleState createState() => _ManagePickupScheduleState();
}

class _ManagePickupScheduleState extends State<ManagePickupSchedule> {
  final CollectionReference pickupScheduleCollection =
      FirebaseFirestore.instance.collection('pickup_schedule');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Manage Pickup Schedule'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pickupScheduleCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(); // Display a loading indicator
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var scheduleData =
                  documents[index].data() as Map<String, dynamic>;

              return ExpansionTile(
                title: Text(scheduleData['name']),
                children: <Widget>[
                  ListTile(
                    title: Text('Phone Number: ${scheduleData['contact']}'),
                    //subtitle: Text('Driver: ${scheduleData['driver']}'),
                  ),
                  ListTile(
                    title: Text('Monday Area:${scheduleData['Monday']}'),
                  ),
                  ListTile(
                    title: Text('Tuesday Area: ${scheduleData['Tuesday']}'),
                  ),
                  ListTile(
                    title: Text(
                        'Thursday Area: ${scheduleData['additionalInfo']}'),
                  ),
                  ListTile(
                    title: Text('Wednesday Area: ${scheduleData['Wednesday']}'),
                  ),
                  ListTile(
                    title: Text('Thursday Area: ${scheduleData['Thursday']}'),
                  ),
                  ListTile(
                    title: Text('Friday Area: ${scheduleData['Friday']}'),
                  ),
                  ListTile(
                    title: Text('Saturday Area: ${scheduleData['Saturday']}'),
                  ),
                  // Add more ListTile widgets for other details
                ],
              );
            },
          );
        },
      ),
    );
  }
}
