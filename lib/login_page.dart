import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_page.dart';
import 'board_list_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  bool isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BoardListPage()),
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
      appBar: AppBar(title: Text('Login')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  _buildTextField('Email', false,
                      validator: (v) => v!.contains('@') ? null : 'Invalid email',
                      onSaved: (v) => email = v!.trim()),
                  _buildTextField('Password', true,
                      validator: (v) => v!.length >= 6 ? null : 'Min 6 chars',
                      onSaved: (v) => password = v!.trim()),
                  SizedBox(height: 24),
                  ElevatedButton(onPressed: _login, child: Text('Login')),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    ),
                    child: Text("Don't have an account? Register"),
                  ),
                ]),
              ),
            ),
    );
  }
}
