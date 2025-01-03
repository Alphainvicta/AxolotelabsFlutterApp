import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key});
  @override
  _CloudScreenState createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  List<String> _imageNames = [];
  final Uri _uploadUri = Uri.parse('https://app.axolotelabs.com/ftp.php');
  final String _cloudUrl = 'https://app.axolotelabs.com/cloud/';

  @override
  void initState() {
    super.initState();
    _loadImageNames();
  }

  Future<void> _loadImageNames() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imageNames = prefs.getStringList('imageNames') ?? [];
    });
  }

  Future<void> _saveImageName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    _imageNames.add(name);
    await prefs.setStringList('imageNames', _imageNames);
    setState(() {});
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
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);

        if (decodedData is Map && decodedData.containsKey('filename')) {
          // Get filename from response and save it locally
          final imageName = decodedData['filename'];
          await _saveImageName(imageName);
          _showMessage('Image uploaded successfully');
        } else {
          _showError('Unexpected response format');
        }
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
            child: _imageNames.isEmpty
                ? Center(child: Text('No images found'))
                : ListView.builder(
                    itemCount: _imageNames.length,
                    itemBuilder: (context, index) {
                      final imageUrl = '$_cloudUrl${_imageNames[index]}';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Text('Failed to load image'),
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
