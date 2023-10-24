import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSchedule extends StatefulWidget {
  final String userEmail;

  ManageSchedule({required this.userEmail});

  @override
  _ManageScheduleState createState() => _ManageScheduleState();
}

class _ManageScheduleState extends State<ManageSchedule> {
  List<String> areas = [
    'Kothrud',
    'Shivaji Nagar',
    'Sinhgad Road',
    'Koregaon Park',
    'Camp',
    'Mundhwa',
    'Kondhwa',
    'Wagholi',
    'Erandwane',
    'Dapodi',
    'Bopodi',
    'Pimpri',
    'Chinchwad',
    'Talegaon',
  ];

  String name = ''; // You can add logic to populate this field
  String contact = ''; // You can add logic to populate this field

  Map<String, String?> dayToArea = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
  };

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Manage Schedule'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(labelText: 'Contact'),
                onChanged: (value) {
                  setState(() {
                    contact = value;
                  });
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dayToArea.keys.map((day) {
                    return Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(day, style: TextStyle(fontSize: 18)),
                          Spacer(),
                          _buildDropdown(day, dayToArea[day]),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
              onPressed: _saveScheduleToFirebase,
              child: Text('Save Schedule', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String day, String? selectedArea) {
    return DropdownButton<String>(
      value: selectedArea,
      onChanged: (value) {
        setState(() {
          dayToArea[day] = value;
        });
      },
      items: areas.map((area) {
        return DropdownMenuItem<String>(
          value: area,
          child: Text(area),
        );
      }).toList(),
    );
  }

  void _saveScheduleToFirebase() {
    final user = widget.userEmail;
    Map<String, dynamic> scheduleData = {
      'name': name,
      'contact': contact,
      'email': user,
      'mondayArea': dayToArea['Monday'],
      'tuesdayArea': dayToArea['Tuesday'],
      'wednesdayArea': dayToArea['Wednesday'],
      'thursdayArea': dayToArea['Thursday'],
      'fridayArea': dayToArea['Friday'],
    };
    firestore.collection('pickup_schedule').doc(user).set(scheduleData);
    Navigator.pop(context);
  }
}
