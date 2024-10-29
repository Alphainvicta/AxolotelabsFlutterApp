import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Mannager.dart'; // Import MannagerScreen for GlobalKey access

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MannagerScreenState? mannagerScreenState =
        context.findAncestorStateOfType<MannagerScreenState>();

    final userData = UserDataProvider.of(context)?.userData;

    String fullname = userData?['full_name'];
    String username = userData?['username'];
    String email = userData?['email'];
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
              'images/AccountDetails.svg', // SVG background path
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              // Account Details Text
              const Text(
                'Account details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
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

              const SizedBox(height: 30),
              // Account Information
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username: $username',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Full name: $fullname',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Email: $email',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Password: ******',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Modify Account Details'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Switch to ModifyAccount tab
                          mannagerScreenState?.accountScreens(4);
                        },
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
