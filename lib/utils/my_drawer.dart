import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../pages/home_page.dart';

class Drawer extends StatefulWidget {
  const Drawer({super.key, required ListView child});

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<Drawer> {
  String _name = 'User';
  String _imagePath = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load preferences (name and image path)
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'User';
      _imagePath = prefs.getString('imagePath') ?? '';
    });
  }

  // Save name and image path to preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _name);
    prefs.setString('imagePath', _imagePath);
  }

  // Function to pick image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
      _savePreferences(); // Save image path
    }
  }

  // Show dialog to edit name
  Future<String?> _showEditDialog() async {
    TextEditingController controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with CircleAvatar
          UserAccountsDrawerHeader(
            accountName: Text(_name),
            accountEmail: Text('example@mail.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _imagePath.isNotEmpty
                  ? FileImage(File(_imagePath))
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            onDetailsPressed: () async {
              // Change user details (name, image)
              final newName = await _showEditDialog();
              if (newName != null) {
                setState(() {
                  _name = newName;
                });
                _savePreferences();
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              // Navigate to home page or refresh current page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()), // Assuming HomePage() exists
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text('Change Avatar'),
            onTap: _pickImage,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Navigate to settings page if you need
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              // Handle logout if needed
            },
          ),
        ],
      ),
    );
  }
}
