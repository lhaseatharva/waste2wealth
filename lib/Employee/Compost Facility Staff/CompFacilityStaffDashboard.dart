import 'package:flutter/material.dart';

class CompFacilityStaffDashboard extends StatefulWidget {
  @override
  _CompFacilityStaffDashboardState createState() =>
      _CompFacilityStaffDashboardState();
}

class _CompFacilityStaffDashboardState
    extends State<CompFacilityStaffDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compost Facility Management'),
        backgroundColor:
            Colors.deepOrange, // Change AppBar color to deep orange
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.deepOrange,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'user@example.com', // Replace with the user's email
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Log Out'),
              leading: Icon(Icons.exit_to_app),
              onTap: () {
                // Handle log out
              },
            ),
          ],
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Single button in each row
          childAspectRatio: 3.0, // Controls the height of each grid item
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(16),
            child: InkWell(
              onTap: () => _handleButtonTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Online icons for each button
                  _getButtonIcon(index),
                  SizedBox(height: 8),
                  Text(
                    _getButtonLabel(index),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleButtonTap(int index) {
    switch (index) {
      case 0:
        // Task: Manage Waste
        _manageWaste();
        break;
      case 1:
        // Task: Allocate Bins to Waste
        _allocateBinsToWaste();
        break;
      case 2:
        // Task: Supervise Compost Manufacturing
        _superviseCompostManufacturing();
        break;
      case 3:
        // Task: Update Compost Stock
        _updateCompostStock();
        break;
    }
  }

  String _getButtonLabel(int index) {
    switch (index) {
      case 0:
        return 'Manage Waste';
      case 1:
        return 'Allocate Bins to Waste';
      case 2:
        return 'Supervise Compost Manufacturing';
      case 3:
        return 'Update Compost Stock';
      default:
        return '';
    }
  }

  Widget _getButtonIcon(int index) {
    String imageUrl = ''; // Set the URL of the icon for each button

    switch (index) {
      case 0:
        imageUrl = 'https://cdn-icons-png.flaticon.com/128/10205/10205395.png';
        break;
      case 1:
        imageUrl = 'https://cdn-icons-png.flaticon.com/128/4660/4660787.png';
        break;
      case 2:
        imageUrl = 'https://cdn-icons-png.flaticon.com/128/2622/2622171.png';
        break;
      case 3:
        imageUrl = 'https://cdn-icons-png.flaticon.com/128/2897/2897785.png';
        break;
    }

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 64,
        height: 64,
      );
    } else {
      return SizedBox.shrink(); // Empty space if no match
    }
  }

  void _manageWaste() {
    // Implement the logic for managing waste here
    // You can show relevant UI or navigate to a new screen
  }

  void _allocateBinsToWaste() {
    // Implement the logic for allocating bins to waste here
    // You can show relevant UI or navigate to a new screen
  }

  void _superviseCompostManufacturing() {
    // Implement the logic for supervising compost manufacturing here
    // You can show relevant UI or navigate to a new screen
  }

  void _updateCompostStock() {
    // Implement the logic for updating compost stock here
    // You can show relevant UI or navigate to a new screen
  }
}
