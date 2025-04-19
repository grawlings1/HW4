import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'nav_drawer.dart';

class ChatPage extends StatefulWidget {
  final String boardName;
  const ChatPage({Key? key, required this.boardName}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _textController = TextEditingController();

  Stream<QuerySnapshot> get _messageStream =>
      FirebaseFirestore.instance
          .collection('messages')
          .where('board', isEqualTo: widget.boardName)
          .orderBy('timestamp')
          .snapshots();

  Future<void> _sendMessage() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final data = userDoc.data();
      String username;
      if (data != null &&
          data['firstName'] != null &&
          data['lastName'] != null) {
        username = '${data['firstName']} ${data['lastName']}';
      } else {
        username = user!.email ?? 'Unknown';
      }
      await FirebaseFirestore.instance.collection('messages').add({
        'board': widget.boardName,
        'userId': user!.uid,
        'username': username,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _textController.clear();
    } catch (e, st) {
      debugPrint('Error sending message: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      drawer: NavDrawer(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  debugPrint('Stream error: $error');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error loading messages:\n${error.toString()}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hello!'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final msg = docs[i].data() as Map<String, dynamic>;
                    final Timestamp? timestamp =
                        docs[i]['timestamp'] as Timestamp?;
                    final DateTime? ts = timestamp?.toDate();
                    final String time = ts != null
                        ? '${ts.hour}:${ts.minute.toString().padLeft(2, '0')}'
                        : '';
                    return ListTile(
                      title: Text(msg['username'] ?? ''),
                      subtitle: Text(msg['message'] ?? ''),
                      trailing: Text(time),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
