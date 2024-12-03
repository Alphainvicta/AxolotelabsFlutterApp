import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    int? subscription = userData?['subscription'];
    String? profilePicture = userData?['profile_picture'];
    String baseUrl = 'https://app.axolotelabs.com/profile_images/';

    String? password;

    String subscriptionStatus = (subscription == 1)
        ? 'Subscription: Subscribed'
        : 'Subscription: Not Subscribed';

    Future<bool> _verifyPassword(String inputPassword) async {
      // Compare with the stored password
      return inputPassword == password;
    }

    Future<void> _promptPasswordVerification(BuildContext context) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      password = prefs.getString('password');
      TextEditingController passwordController = TextEditingController();

      bool isVerified = false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Password Verification'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please enter your password to proceed:'),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  isVerified = await _verifyPassword(passwordController.text);
                  if (isVerified) {
                    // Save unhashed password to SharedPreferences
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString(
                        'unhashed_password', passwordController.text);

                    Navigator.pop(context); // Close the dialog
                    mannagerScreenState?.accountScreens(
                        4); // Navigate to Modify Account screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid password. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'images/AccountDetails.svg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Account details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: profilePicture != null
                    ? NetworkImage('$baseUrl$profilePicture')
                    : null,
                child: profilePicture == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              const SizedBox(height: 30),
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
                        offset: const Offset(0, 3),
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
                            const SizedBox(height: 10),
                            Text(
                              subscriptionStatus,
                              style: const TextStyle(
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
                        onTap: () async {
                          await _promptPasswordVerification(context);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: Text(subscription == 1
                            ? 'Cloud Images'
                            : 'Subscription Details'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          if (subscription == 1) {
                            mannagerScreenState
                                ?.accountScreens(6); // Navigate to Cloud Images
                          } else {
                            mannagerScreenState?.accountScreens(
                                5); // Navigate to Subscription Details
                          }
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
