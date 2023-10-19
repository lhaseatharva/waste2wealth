import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waste2wealth/BuyerDashboard.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste2wealth/EmployeeDashboard.dart';
import 'package:waste2wealth/LoginPage.dart';
import 'package:waste2wealth/MyRequestsPage.dart';
import 'package:waste2wealth/RegistrationPage.dart';
import 'package:waste2wealth/WelcomePage.dart';
import 'package:waste2wealth/RestaurantDashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      initialRoute: '/', // Set the initial route to '/'
      routes: {
        '/': (context) => WelcomePage(), // WelcomePage is the first page
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/restaurant': (context) => RestaurantDashboard(),
        '/employee': (context) => EmployeeDashboard(),
        '/my_requests': (context) => MyRequestsPage(),
        '/buyer': (context) => BuyerDashboard(),
      },
    );
  }
}
