import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String userId;

  const ChatPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with user $userId'),
      ),
      body: Center(
        child: Text('Chat UI will be here.'),
      ),
    );
  }
}
