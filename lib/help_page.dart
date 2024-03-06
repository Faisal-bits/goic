import 'package:flutter/material.dart';
// Assuming ChatbotPage is another widget you have for displaying the chat interface
// import 'chatbot_page.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool showChatbot = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
        actions: [
          IconButton(
            icon: Icon(showChatbot ? Icons.list : Icons.chat),
            onPressed: () {
              setState(() {
                showChatbot = !showChatbot;
              });
            },
          ),
        ],
      ),
      body: showChatbot
          ? Center(
              child: Text(
                  "Chatbot Placeholder")) // Replace with your ChatbotPage widget
          : ListView(
              children: <Widget>[
                _buildExpansionTile("What is this app?", "This app is..."),
                _buildExpansionTile("How do I use it?", "You can use it by..."),
                _buildExpansionTile("What is GID?", "GID stands for..."),
                // Add more questions here
              ],
            ),
    );
  }

  Widget _buildExpansionTile(String title, String answer) {
    return ExpansionTile(
      title: Text(title),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
