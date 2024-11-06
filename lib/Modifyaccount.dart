import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModifyAccountScreen extends StatefulWidget {
  final VoidCallback? onRefresh; // Make onRefresh nullable

  const ModifyAccountScreen({Key? key, this.onRefresh}) : super(key: key);

  @override
  _ModifyAccountScreenState createState() => _ModifyAccountScreenState();
}

class _ModifyAccountScreenState extends State<ModifyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? userEmail; // To store the fetched email

  File? _image; // Holds the selected image
  final ImagePicker _picker = ImagePicker();

  // Method to select image (from camera or gallery)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  // Method to handle updating user data
  Future<void> _updateUser(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email');

    if (_formKey.currentState!.validate()) {
      // Prepare data for the request
      final Map<String, String> requestData = {
        'current_email': userEmail.toString(),
      };

      // Add optional fields if they are filled
      if (_firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty) {
        requestData['full_name'] =
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      }

      if (_firstNameController.text.isNotEmpty) {
        requestData['first_name'] = _firstNameController.text;
      }

      if (_lastNameController.text.isNotEmpty) {
        requestData['last_name'] = _lastNameController.text;
      }

      if (_usernameController.text.isNotEmpty) {
        requestData['username'] = _usernameController.text;
      }
      if (_emailController.text.isNotEmpty) {
        requestData['new_email'] = _emailController.text;
      }
      if (_passwordController.text.isNotEmpty) {
        requestData['password'] = _passwordController.text;
      }

      // Prepare to upload image if selected
      if (_image != null) {
        var request = http.MultipartRequest(
            'POST', Uri.parse('https://app.axolotelabs.com/modify_user.php'));
        request.fields.addAll(requestData);

        // Add image file
        request.files.add(
            await http.MultipartFile.fromPath('profile_picture', _image!.path));

        // Send the request
        var response = await request.send();
        final responseData = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          final result = json.decode(responseData.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['success'] ?? result['error'])),
          );

          // Call onRefresh after successful update
          widget.onRefresh?.call();
          await prefs.setString(
              'email',
              _emailController.text.isNotEmpty
                  ? _emailController.text
                  : userEmail.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Failed to update user.')),
          );
        }
      } else {
        // Send request without image
        final response = await http.post(
          Uri.parse('https://app.axolotelabs.com/modify_user.php'),
          body: requestData,
        );

        final result = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['success'] ?? result['error'])),
        );

        // Call onRefresh after successful update
        if (response.statusCode == 200) {
          widget.onRefresh?.call();
          await prefs.setString(
              'email',
              _emailController.text.isNotEmpty
                  ? _emailController.text
                  : userEmail.toString());
        }
      }
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
              'images/ModifyAccount.svg', // SVG background path
              fit: BoxFit.cover,
            ),
          ),
          // Wrapping the entire form in a SingleChildScrollView to make it scrollable
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Modify Data',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Profile Picture (with camera/gallery access)
                          GestureDetector(
                            onTap: () => _showImagePicker(context),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  _image != null ? FileImage(_image!) : null,
                              child: _image == null
                                  ? const Icon(Icons.image, size: 40)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // First Name and Last Name Fields in a Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    hintText: 'First name',
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintStyle: TextStyle(fontSize: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFD8D8D8)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10), // Space between fields
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Last name',
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintStyle: TextStyle(fontSize: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFD8D8D8)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Username',
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD8D8D8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD8D8D8)),
                              ),
                            ),
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Confirm Email Field
                          TextFormField(
                            controller: _confirmEmailController,
                            decoration: InputDecoration(
                              hintText: 'Confirm Email',
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD8D8D8)),
                              ),
                            ),
                            validator: (value) {
                              if (_emailController.text.isNotEmpty &&
                                  (value == null || value.isEmpty)) {
                                return 'Please confirm your email';
                              } else if (value != _emailController.text) {
                                return 'Emails do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD8D8D8)),
                              ),
                            ),
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD8D8D8)),
                              ),
                            ),
                            validator: (value) {
                              if (_passwordController.text.isNotEmpty &&
                                  (value == null || value.isEmpty)) {
                                return 'Please confirm your password';
                              } else if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Save Changes Button
                          SizedBox(
                            height: 60,
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () => _updateUser(context),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor:
                                    const Color(0xFF7C34E9), // Button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show options for picking an image
  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
