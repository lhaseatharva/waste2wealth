import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/Admin/AdminPanel.dart';

class CompostStockManagement extends StatefulWidget {
  @override
  _CompostStockManagementState createState() => _CompostStockManagementState();
}

class _CompostStockManagementState extends State<CompostStockManagement> {
  final CollectionReference compostStockCollection =
      FirebaseFirestore.instance.collection('compost_stock');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Compost Stock Management'),
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
          future: compostStockCollection.get(),
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
                var compostStockData =
                    documents[index].data() as Map<String, dynamic>;
                final documentName = documents[index].id;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Compost Type: $documentName'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Price Per kg: ${compostStockData['pricePerKg']?.toString() ?? 'No Price'}'),
                        Text(
                            'Quantity: ${compostStockData['quantity']?.toString() ?? 'No Quantity'}'),
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
