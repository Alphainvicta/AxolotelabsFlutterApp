import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'Mannager.dart'; // Import MannagerScreen for GlobalKey access

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    final userData = UserDataProvider.of(context)?.userData;
    final messageData = _messageController.text.trim();

    if (messageData.isEmpty) {
      // Show a message if the text field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message field is required')),
      );
      return;
    }

    final nameData = userData?['full_name'];
    final emailData = userData?['email'];

    if (nameData == null || emailData == null) {
      // Handle missing user data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data is missing')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.axolotelabs.com/email.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nameData': nameData,
          'emailData': emailData,
          'messageData': messageData,
        },
      );

      if (response.statusCode == 200) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quote request sent successfully')),
        );
        _messageController.clear();
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send quote request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'images/Quote.svg', // SVG background path
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Title
                    const Text(
                      'Get in touch!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Contact Info Box
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our team is here to help. Contact us for fast and friendly support.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 40),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.phone, color: Color(0xFFEF5DA8)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '+52 3319128876',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.email, color: Color(0xFFEF5DA8)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'cotizaciones@axolotelabs.com',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Message Text Area
                    SizedBox(
                      height: 200, // Adjust height to ensure scroll behavior
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: Color(0xFFD8D8D8)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: Color(0xFFD8D8D8)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Submit Button
                    SizedBox(
                      height: 60,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor:
                              const Color(0xFFEF5DA8), // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : const Text(
                                'Quote',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
