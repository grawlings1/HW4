import 'package:flutter/material.dart';
import 'board_list_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Message Boards'),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BoardListPage()),
          ),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          ),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SettingsPage()),
          ),
        ),
      ]),
    );
  }
}
