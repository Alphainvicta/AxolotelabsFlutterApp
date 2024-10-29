import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFefe6ee), // Solid background color

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), // Space from the top
              // Main Title
              Text(
                'Our services',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 40), // Space between title and first service

              // Service 1: Web and Mobile Apps
              ServiceItem(
                imagePath:
                    'images/Service_card_react.png', // Replace with actual asset path
                subtitle: 'Web and Mobile Apps',
                description:
                    'Have your own page to advertise your business, sell products with an online store or your menu/catalog quick and easy with a QR code.',
              ),

              SizedBox(height: 40), // Space between services

              // Service 2: Interactive Software
              ServiceItem(
                imagePath:
                    'images/Service_card_interactive.png', // Replace with actual asset path
                subtitle: 'Interactive Software',
                description:
                    'Virtual tours, whether with a computer and phone or full immersion with VR headsets, games for exhibitions or events, virtual reality or augmented reality software.',
              ),

              SizedBox(height: 40), // Space between services

              // Service 3: Databases with User Interface
              ServiceItem(
                imagePath:
                    'images/Service_card_postgreesql.png', // Replace with actual asset path
                subtitle: 'Databases with User Interface',
                description:
                    'Databases to keep your business organized, whether it’s to manage inventory, staff, record appointments, meetings, schedules, departures or arrivals. Keep control and record of everything that happens in your business!',
              ),

              SizedBox(height: 40), // Space before the bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String imagePath;
  final String subtitle;
  final String description;

  const ServiceItem({
    super.key,
    required this.imagePath,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Service Image
        Image.asset(
          imagePath,
          height: 250,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),

        // Service Subtitle
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),

        // Service Description
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
