import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';
import 'Mannager.dart'; // Import MannagerScreen for GlobalKey access
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Method to handle sign-out logic
  Future<void> _handleSignOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear login data

    // Navigate back to LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MannagerScreenState? mannagerScreenState =
        context.findAncestorStateOfType<MannagerScreenState>();

    final userData = UserDataProvider.of(context)?.userData;

    String username = userData?['username'] ?? "user";
    String? profilePicture =
        userData?['profile_picture']; // Get profile picture URL
    String baseUrl =
        'https://app.axolotelabs.com/profile_images/'; // Base URL for images

    return Scaffold(
      body: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'images/Home.svg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              // User Image
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: profilePicture != null
                    ? NetworkImage('$baseUrl$profilePicture')
                    : null, // Use the profile image if available
                child: profilePicture == null
                    ? const Icon(Icons.person, size: 60) // Default icon
                    : null, // No child when image is used
              ),
              const SizedBox(height: 20),
              // Welcome Text
              Text(
                'Welcome back\n$username!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              // Menu Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const FaIcon(FontAwesomeIcons.user),
                        title: const Text('Account Details'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Switch to AccountDetails tab
                          mannagerScreenState?.accountScreens(3);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: FaIcon(FontAwesomeIcons.magnifyingGlass),
                        title: const Text('Look for Services'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Switch to Services tab
                          mannagerScreenState?.onItemTapped(1);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: FaIcon(FontAwesomeIcons.noteSticky),
                        title: const Text('Quote'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Switch to Quote tab
                          mannagerScreenState?.onItemTapped(2);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const FaIcon(FontAwesomeIcons.doorOpen,
                            color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.red),
                        onTap: () => _handleSignOut(context), // Handle logout
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
