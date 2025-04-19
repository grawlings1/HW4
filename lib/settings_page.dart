import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'nav_drawer.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  final _emailFormKey = GlobalKey<FormState>();
  final _passFormKey  = GlobalKey<FormState>();
  String newEmail    = '';
  String newPassword = '';

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  Future<void> _updateEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    _emailFormKey.currentState!.save();
    try {
      await user!.updateEmail(newEmail);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Email updated')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _updatePassword() async {
    if (!_passFormKey.currentState!.validate()) return;
    _passFormKey.currentState!.save();
    try {
      await user!.updatePassword(newPassword);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Password updated')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
      appBar: AppBar(title: Text('Settings')),
      drawer: NavDrawer(),
      body: ListView(padding: EdgeInsets.all(16), children: [
        ElevatedButton(onPressed: _logout, child: Text('Logout')),
        Divider(),
        Form(
          key: _emailFormKey,
          child: Column(children: [
            Text('Change Email', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildTextField('New Email', false,
                validator: (v) => v!.contains('@') ? null : 'Invalid email',
                onSaved: (v) => newEmail = v!.trim()),
            ElevatedButton(onPressed: _updateEmail, child: Text('Update Email')),
          ]),
        ),
        Divider(),
        Form(
          key: _passFormKey,
          child: Column(children: [
            Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildTextField('New Password', true,
                validator: (v) => v!.length >= 6 ? null : 'Min 6 chars',
                onSaved: (v) => newPassword = v!.trim()),
            ElevatedButton(onPressed: _updatePassword, child: Text('Update Password')),
          ]),
        ),
      ]),
    );
  }
}
