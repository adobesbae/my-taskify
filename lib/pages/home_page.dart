import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_taskify/utils/my_taskify.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Task List
  List myTaskify = [
    ['Learn Flutter', false],
    ['Drink Coffee', false],
    ['Code with Zahra', false],
  ];

  // Profile Information
  String _name = "Your Name";
  String _email = "example@example.com";
  Uint8List? _webProfileImageBytes; // For web
  String? _profileImagePath; // For Android/iOS

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "Your Name";
      _email = prefs.getString('email') ?? "example@example.com";
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  // Update name in SharedPreferences
  Future<void> _updateName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    setState(() {
      _name = name;
    });
  }

  // Update email in SharedPreferences
  Future<void> _updateEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    setState(() {
      _email = email;
    });
  }

  // Update profile image in SharedPreferences
  Future<void> _updateProfileImage(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
    setState(() {
      _profileImagePath = path;
    });
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    if (kIsWeb) {
      // Web-specific handling
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webProfileImageBytes = bytes;
        });
      }
    } else {
      // Mobile and other platforms
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _updateProfileImage(pickedFile.path);
      }
    }
  }

  // Open settings dialog to change name and email
  void _openSettings() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Settings"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  hintText: "Enter your name",
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              String newName = nameController.text.trim();
              String newEmail = emailController.text.trim();

              if (newName.isNotEmpty) {
                _updateName(newName);
              }

              if (newEmail.isNotEmpty) {
                _updateEmail(newEmail);
              }

              Navigator.of(context).pop();
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // Task Management Methods
  void checkBoxChanged(int index) {
    setState(() {
      myTaskify[index][1] = !myTaskify[index][1];
    });
  }

  void saveNewTask() {
    String newTask = _controller.text.trim();
    if (newTask.isNotEmpty) {
      setState(() {
        myTaskify.add([newTask, false]);
        _controller.clear();
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void deleteTask(int index) {
    setState(() {
      myTaskify.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.orangeAccent,
        ),
        title: const Text(
          'My Taskify',
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_name),
              accountEmail: Text(_email),
              currentAccountPicture: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  backgroundImage: kIsWeb
                      ? _webProfileImageBytes != null
                          ? MemoryImage(_webProfileImageBytes!)
                          : null
                      : _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                  child:
                      _webProfileImageBytes == null && _profileImagePath == null
                          ? Icon(Icons.person, color: Colors.black, size: 40)
                          : null,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white,),
              title: Text("Home", style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Colors.white,),
              title: Text("Pick Image", style: TextStyle( color: Colors.white,),),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white,),
              title: Text("Settings", style: TextStyle( color: Colors.white,)),
              onTap: () {
                Navigator.pop(context);
                _openSettings();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: myTaskify.length,
        itemBuilder: (BuildContext context, index) {
          return MyTaskify(
            taskName: myTaskify[index][0],
            taskCompleted: myTaskify[index][1],
            onChanged: (value) => checkBoxChanged(index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add a new task',
                    fillColor: Colors.orangeAccent,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              onPressed: saveNewTask,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
