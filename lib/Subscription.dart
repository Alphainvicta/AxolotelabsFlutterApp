import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback? onRefresh; // Make onRefresh nullable

  const SubscriptionScreen({Key? key, this.onRefresh}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _email;
  int? _selectedMonth = 1; // Default subscription option

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  // Fetch email from SharedPreferences
  _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email'); // Replace 'email' with the actual key
    });
  }

  // Submit subscription data
  _submitSubscription() async {
    if (_email == null) {
      // Handle the case where email is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email not found in SharedPreferences')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://app.axolotelabs.com/subscription.php'),
      body: {
        'email': _email!,
        'subscription_duration': _selectedMonth.toString(),
      },
    );

    if (response.statusCode == 200) {
      // Handle successful response
      final result = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['success'] ?? 'Subscription successful!')),
      );

      // Call onRefresh after successful subscription
      widget.onRefresh?.call();
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background SVG image
          Positioned.fill(
            child: SvgPicture.asset(
              'images/Subscriptiondetails.svg',
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Text(
                  'Subscription details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Card details form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Card number'),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Card date'),
                                SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CCV'),
                                SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('Months'),
                      SizedBox(height: 8),
                      // Radio buttons for subscription months
                      Column(
                        children: [
                          _buildSubscriptionOption(1),
                          _buildSubscriptionOption(3),
                          _buildSubscriptionOption(12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Save Changes Button
              SizedBox(
                height: 60,
                width: 150,
                child: ElevatedButton(
                  onPressed: _submitSubscription,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(0xFF7C34E9), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Subscribe',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for subscription options
  Widget _buildSubscriptionOption(int months) {
    return Row(
      children: [
        Radio<int>(
          value: months,
          groupValue: _selectedMonth,
          onChanged: (value) {
            setState(() {
              _selectedMonth = value;
            });
          },
        ),
        Text('$months months'),
      ],
    );
  }
}
