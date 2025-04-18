import 'package:flutter/material.dart';
import 'nav_drawer.dart';
import 'chat_page.dart';

class BoardListPage extends StatelessWidget {
  final List<Map<String, String>> boards = [
    {'name': 'General', 'icon': 'assets/general.png'},
    {'name': 'Technology', 'icon': 'assets/technology.png'},
    {'name': 'Random', 'icon': 'assets/random.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Message Boards')),
      drawer: NavDrawer(),
      body: ListView.builder(
        itemCount: boards.length,
        itemBuilder: (context, index) {
          final board = boards[index];
          return ListTile(
            leading: Image.asset(board['icon']!),
            title: Text(board['name']!),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(boardName: board['name']!),
              ),
            ),
          );
        },
      ),
    );
  }
}
