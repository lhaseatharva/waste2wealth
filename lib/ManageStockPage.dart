import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    home: ManageStockPage(),
  ));
}

class ManageStockPage extends StatefulWidget {
  @override
  _ManageStockPageState createState() => _ManageStockPageState();
}

class _ManageStockPageState extends State<ManageStockPage> {
  int currentOrganicCompostStock = 0;
  int currentVermicompostStock = 0;
  bool stockInitialized = false;
  bool showUpdateForm = false; // To show/hide the stock update form
  final _rateController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedCategory = 'Organic Compost'; // Default category value

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    final organicCompostDoc = await FirebaseFirestore.instance
        .collection('stock')
        .doc('OrganicCompost')
        .get();
    final vermicompostDoc = await FirebaseFirestore.instance
        .collection('stock')
        .doc('Vermicompost')
        .get();

    final organicCompostData =
        organicCompostDoc.data() as Map<String, dynamic>?;
    final vermicompostData = vermicompostDoc.data() as Map<String, dynamic>?;

    if (organicCompostData != null) {
      currentOrganicCompostStock = organicCompostData['quantity'] ?? 0;
    }

    if (vermicompostData != null) {
      currentVermicompostStock = vermicompostData['quantity'] ?? 0;
    }

    setState(() {
      stockInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Manage Stock'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!showUpdateForm) // Show Stock squares only if the form is not shown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildStockSquare(
                    title: 'Stock Available',
                    value:
                        (currentOrganicCompostStock + currentVermicompostStock)
                            .toString(),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showUpdateForm = !showUpdateForm;
                      });
                    },
                    child: _buildStockSquareWithIcon(
                      title: 'Add Stock',
                      icon: Icons.add,
                    ),
                  ),
                ],
              ),
            if (showUpdateForm) _buildStockUpdateForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSquare({required String title, required String value}) {
    return Container(
      width: 150,
      height: 150,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSquareWithIcon(
      {required String title, required IconData icon}) {
    return Container(
      width: 150,
      height: 150,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade200, // Background color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStockUpdateForm() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepOrange.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Stock Update Form',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: <String>['Organic Compost', 'Vermicompost']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _rateController,
              decoration: InputDecoration(
                labelText: 'Rate per kg',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity in kg',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _handleSubmitButton();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.deepOrange.shade200),
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitButton() async {
    final rate = int.tryParse(_rateController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;

    final firestore = FirebaseFirestore.instance;
    final documentName = _selectedCategory.replaceAll(' ', '');

    await firestore.collection('stock').doc(documentName).set({
      'category': _selectedCategory,
      'rate': rate,
      'quantity': quantity,
    });

    setState(() {
      showUpdateForm = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stock updated successfully'),
      ),
    );

    _rateController.clear();
    _quantityController.clear();

    await _loadStockData();
  }
}
