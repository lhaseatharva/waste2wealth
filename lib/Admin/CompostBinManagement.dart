import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/Admin/AdminPanel.dart';

class CompostBinManagement extends StatefulWidget {
  @override
  _CompostBinManagementState createState() => _CompostBinManagementState();
}

class _CompostBinManagementState extends State<CompostBinManagement> {
  final CollectionReference compostBinsCollection =
      FirebaseFirestore.instance.collection('compost_bins');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Compost Bin Management'),
          backgroundColor: Colors.deepOrange,
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
        body: FutureBuilder<QuerySnapshot>(
          future: compostBinsCollection.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final documents = snapshot.data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var compostBinData =
                    documents[index].data() as Map<String, dynamic>;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Details for: ${documents[index].id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Current Quantity: ${compostBinData['currQty']?.toString() ?? 'No Data'}'),
                        Text(
                            'Maximum Quantity: ${compostBinData['maxQty']?.toString() ?? 'No Data'}'),
                        if (compostBinData['waste'] != null)
                          for (var wasteKey in compostBinData['waste'].keys)
                            Text(
                                '$wasteKey: ${compostBinData['waste'][wasteKey]}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
