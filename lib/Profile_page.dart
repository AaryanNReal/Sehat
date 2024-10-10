import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_page.dart'; // Import your authentication page here

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String _userName = '';
  int? _age;
  double? _weight;
  double? _height;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Load user information from FirebaseAuth and Firestore
  Future<void> _loadUser() async {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });

    if (_user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      setState(() {
        _userName = userData['name'] ?? '';
        _age = userData['age'] ?? 0;
        _weight = (userData['weight'] ?? 0).toDouble();
        _height = (userData['height'] ?? 0).toDouble();
      });
    }
  }

  // Update profile details in Firestore
  Future<void> _updateProfile() async {
    if (_user != null && _nameController.text.isNotEmpty && _ageController.text.isNotEmpty &&
        _weightController.text.isNotEmpty && _heightController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'weight': double.parse(_weightController.text),
        'height': double.parse(_heightController.text),
      });

      setState(() {
        _userName = _nameController.text;
        _age = int.parse(_ageController.text);
        _weight = double.parse(_weightController.text);
        _height = double.parse(_heightController.text);
        _isEditing = false; // Stop editing after update
      });
    }
  }

  // Sign out the user
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _user = null;
      _userName = '';
    });
  }

  // Navigate to login/signup page
  void _navigateToAuthPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    ).then((_) {
      _loadUser();  // Refresh user info after returning from AuthPage
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_user != null)
            ElevatedButton(
              onPressed: _signOut,
              child: const Icon(Icons.logout_outlined, color: Colors.black),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: BeveledRectangleBorder(),
              ),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: Colors.teal[100],
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_user == null)
                    Column(
                      children: [
                        const Text(
                          'Welcome!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _navigateToAuthPage,
                          child: const Text('Login / Sign Up'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                  if (_user != null && !_isEditing) ...[
                    const Text(
                      "Profile Information",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 20),
                    Text("Name: $_userName", style: const TextStyle(fontSize: 18)),
                    Text("Age: ${_age ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                    Text("Weight: ${_weight ?? 'N/A'} kg", style: const TextStyle(fontSize: 18)),
                    Text("Height: ${_height ?? 'N/A'} cm", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                          _nameController.text = _userName;
                          _ageController.text = _age?.toString() ?? '';
                          _weightController.text = _weight?.toString() ?? '';
                          _heightController.text = _height?.toString() ?? '';
                        });
                      },
                      child: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],

                  if (_isEditing) ...[
                    const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Age"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Weight (kg)"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Height (cm)"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text("Update Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      child: const Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
