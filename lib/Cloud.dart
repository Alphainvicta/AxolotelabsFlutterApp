import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key});
  @override
  _CloudScreenState createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  List<String> _imageUrls = [];
  final Uri _uploadUri = Uri.parse('https://app.axolotelabs.com/ftp.php');

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      final response = await http.get(_uploadUri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _imageUrls = List<String>.from(data);
        });
      } else {
        _showError('Failed to fetch images');
      }
    } catch (e) {
      _showError('Error fetching images: $e');
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final File imageFile = File(pickedFile.path);

    try {
      final request = http.MultipartRequest('POST', _uploadUri);
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      final response = await request.send();

      if (response.statusCode == 200) {
        _showMessage('Image uploaded successfully');
        _fetchImages();
      } else {
        _showError('Failed to upload image');
      }
    } catch (e) {
      _showError('Error uploading image: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error, style: TextStyle(color: Colors.red))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cloud Images')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: Icon(Icons.add),
              label: Text('Add New Image'),
            ),
          ),
          Expanded(
            child: _imageUrls.isEmpty
                ? Center(child: Text('No images found'))
                : ListView.builder(
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          _imageUrls[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
