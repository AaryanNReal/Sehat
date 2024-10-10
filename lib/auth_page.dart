import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSignup = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_isSignup) {
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': _nameController.text,
          });
        } else {
          await _auth.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
        }
        Navigator.pop(context); // Navigate back after login/signup
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
        ));
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter your email address to reset your password.'),
      ));
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset email sent! Check your inbox.'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send reset email. Please try again later.'),
      ));
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignup ? 'Sign Up' : 'Log In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: _validateEmail,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              if (_isSignup)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isSignup ? 'Sign Up' : 'Log In'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignup = !_isSignup;
                  });
                },
                child: Text(_isSignup
                    ? 'Already have an account? Log In'
                    : 'Don\'t have an account? Sign Up'),
              ),
              if (!_isSignup)
                TextButton(
                  onPressed: _resetPassword,
                  child: Text('Forgot Password? Reset here'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
