import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/Admin/AdminPanel.dart';

class WasteStockManagement extends StatefulWidget {
  @override
  _WasteStockManagementState createState() => _WasteStockManagementState();
}

class _WasteStockManagementState extends State<WasteStockManagement> {
  final CollectionReference wasteStockCollection =
      FirebaseFirestore.instance.collection('waste_stock');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Waste Stock Management'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AdminPanel(adminEmail: ''),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: wasteStockCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var wasteStockData =
                  documents[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                      'Restaurant Name: ${wasteStockData['restaurantName'] ?? 'No Restaurant'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${wasteStockData['type'] ?? 'No Type'}'),
                      Text(
                          'Collected On: ${wasteStockData['collectedOn'] ?? 'No Date'}'),
                      Text(
                          'Weight: ${wasteStockData['weight']?.toString() ?? 'No Weight'}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
