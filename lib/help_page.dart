import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool showChatbot = false; // false for Info, true for Bot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
        actions: [
          // Custom toggle switch between Info and Bot
          _customToggle(),
        ],
      ),
      body: showChatbot
          ? _chatbotInterface() // The enhanced chatbot interface
          : _infoPage(), // The improved information page with drop-downs
    );
  }

  Widget _customToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showChatbot = !showChatbot;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Info',
              style: TextStyle(
                color: showChatbot ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Switch(
            value: showChatbot,
            onChanged: (value) {
              setState(() {
                showChatbot = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Bot',
              style: TextStyle(
                color: showChatbot ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPage() {
    return ListView(
      children: <Widget>[
        _buildExpansionTile("What is this app?", "This app is..."),
        _buildExpansionTile("How do I use it?", "You can use it by..."),
        _buildExpansionTile("What is GID?", "GID stands for..."),
        // Add more questions here
      ],
    );
  }

  Widget _buildExpansionTile(String title, String answer) {
    return ExpansionTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer, textAlign: TextAlign.justify),
        ),
      ],
    );
  }

  Widget _chatbotInterface() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            // This should be dynamically populated with your chat content
            children: [
              _buildChatMessage("Hi! How can I help you today?", isBot: true),
              // Add more dynamic chat messages here
            ],
          ),
        ),
        _buildTextInputField(),
      ],
    );
  }

  Widget _buildChatMessage(String message, {bool isBot = false}) {
    return ListTile(
      title: Text(
        message,
        style: TextStyle(
          color: isBot ? Colors.blue : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type your message here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // Implement sending message functionality here
            },
          ),
        ],
      ),
    );
  }
}
