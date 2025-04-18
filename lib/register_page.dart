import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '', lastName = '', role = '', email = '', password = '';
  bool isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => isLoading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
        .collection('users')
        .doc(userCred.user!.uid)
        .set({
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'registrationDateTime': FieldValue.serverTimestamp(),
        });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTextField(String label, bool obscure,
      {required FormFieldSetter<String> onSaved,
      FormFieldValidator<String>? validator}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      obscureText: obscure,
      validator: validator,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(children: [
                  _buildTextField('First Name', false,
                      validator: (v) => v!.isEmpty ? 'Enter first name' : null,
                      onSaved: (v) => firstName = v!.trim()),
                  _buildTextField('Last Name', false,
                      validator: (v) => v!.isEmpty ? 'Enter last name' : null,
                      onSaved: (v) => lastName = v!.trim()),
                  _buildTextField('Role', false,
                      validator: (v) => v!.isEmpty ? 'Enter role' : null,
                      onSaved: (v) => role = v!.trim()),
                  _buildTextField('Email', false,
                      validator: (v) => v!.contains('@') ? null : 'Invalid email',
                      onSaved: (v) => email = v!.trim()),
                  _buildTextField('Password', true,
                      validator: (v) => v!.length >= 6 ? null : 'Min 6 chars',
                      onSaved: (v) => password = v!.trim()),
                  SizedBox(height: 24),
                  ElevatedButton(onPressed: _register, child: Text('Register')),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    ),
                    child: Text('Already have an account? Login'),
                  ),
                ]),
              ),
            ),
    );
  }
}
