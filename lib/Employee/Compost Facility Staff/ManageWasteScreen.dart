import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageWasteScreen extends StatefulWidget {
  @override
  _ManageWasteScreenState createState() => _ManageWasteScreenState();
}

class _ManageWasteScreenState extends State<ManageWasteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  List<Map<String, dynamic>> _completedRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchCompletedRequests();
  }

  Future<void> _fetchCompletedRequests() async {
    final currentDay = DateFormat('EEEE').format(DateTime.now());

    final querySnapshot = await _firestore
        .collection('pickup_requests')
        .where('status.$currentDay', isEqualTo: 'Complete')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final newCompletedRequests = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      final restaurantNamesInStock = await _getRestaurantNamesInStock();

      final unprocessedRequests = newCompletedRequests.where((request) {
        final restaurantName = request['restaurantName'];
        return !restaurantNamesInStock.contains(restaurantName);
      }).toList();

      setState(() {
        _completedRequests = unprocessedRequests;
      });
    }
  }

  Future<List<String>> _getRestaurantNamesInStock() async {
    final stockQuerySnapshot = await _firestore.collection('waste_stock').get();
    final restaurantNamesInStock = stockQuerySnapshot.docs
        .map((doc) => doc.get('restaurantName') as String)
        .toList();
    return restaurantNamesInStock;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Waste'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        itemCount: _completedRequests.length,
        itemBuilder: (context, index) {
          final request = _completedRequests[index];
          final restaurantName = request['restaurantName'];

          return RequestCard(
            restaurantName: restaurantName,
            onAddToStock: (double weight) {
              _addToStock(restaurantName, weight);
            },
          );
        },
      ),
    );
  }

  void _addToStock(String restaurantName, double weight) {
    final collectedOn = _dateFormat.format(DateTime.now());

    final wasteStockRef =
        _firestore.collection('waste_stock').doc(restaurantName);

    wasteStockRef.set({
      'restaurantName': restaurantName,
      'weight': weight,
      'collectedOn': collectedOn,
      // Add other relevant data fields as needed
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to Waste Stock for $restaurantName'),
        ),
      );
    }).catchError((error) {
      print('Error adding to waste stock: $error');
    });
  }
}

class RequestCard extends StatefulWidget {
  final String restaurantName;
  final Function(double) onAddToStock;

  RequestCard({
    required this.restaurantName,
    required this.onAddToStock,
  });

  @override
  _RequestCardState createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool _isExpanded = false;
  double _weight = 0.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.restaurantName),
            trailing: IconButton(
              icon:
                  Icon(_isExpanded ? Icons.arrow_upward : Icons.arrow_downward),
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
                  Text('Enter Weight (kg)'),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _weight = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_weight > 0) {
                        widget.onAddToStock(_weight);
                      }
                    },
                    child: Text('Add to Stock'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
