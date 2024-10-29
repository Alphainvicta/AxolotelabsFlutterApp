import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

import 'Services.dart';
import 'Home.dart';
import 'Quote.dart';
import 'Accountdetails.dart';
import 'Modifyaccount.dart';

class MannagerScreen extends StatefulWidget {
  const MannagerScreen({super.key});

  @override
  MannagerScreenState createState() => MannagerScreenState();
}

class MannagerScreenState extends State<MannagerScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages; // Use late to initialize in initState

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const ServicesScreen(),
      const QuoteScreen(),
      const AccountDetailsScreen(),
      ModifyAccountScreen(onRefresh: refreshUserData), // Pass the callback here
    ];
    fetchUserData(); // Fetch user data when the screen initializes
  }

  String? userEmail; // To store the fetched email
  Map<String, dynamic>? userData; // To store user data

  // Method to handle navigation when an item is tapped
  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper method to switch to AccountDetails with grey colors on the navbar
  void accountScreens(int index) {
    setState(() {
      _selectedIndex = index; // Switch to Account screens
    });
  }

  Future<void> fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email');
    if (userEmail != null) {
      const String apiUrl = 'https://app.axolotelabs.com/fetch_user_data.php';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'email': userEmail},
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body); // Decode the response
        });
      } else {
        // Handle error response
        print('Failed to load user data: ${response.statusCode}');
      }
    }
  }

  void refreshUserData() {
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return UserDataProvider(
      userData: userData,
      child: Scaffold(
        body: _pages[_selectedIndex], // Show the selected page
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor:
              _selectedIndex > 2 ? Colors.grey : const Color(0xFF7c34e9),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex > 2 ? 0 : _selectedIndex,
          onTap: onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sticky_note_2),
              label: 'Quote',
            ),
          ],
        ),
      ),
    );
  }
}

// InheritedWidget to provide user data
class UserDataProvider extends InheritedWidget {
  final Map<String, dynamic>? userData;

  const UserDataProvider({Key? key, required Widget child, this.userData})
      : super(key: key, child: child);

  static UserDataProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserDataProvider>();
  }

  @override
  bool updateShouldNotify(UserDataProvider oldWidget) {
    return oldWidget.userData != userData; // Update if userData changes
  }
}
