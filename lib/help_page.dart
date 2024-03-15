import 'package:flutter/material.dart';
import 'openai_service.dart'; // Adjust the import path as needed

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool showChatbot = false;
  final TextEditingController _textEditingController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final OpenAIService _openAIService = OpenAIService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
        actions: [
          _customToggle(),
        ],
      ),
      body: showChatbot ? _chatbotInterface() : _infoPage(),
    );
  }

  Widget _customToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background of the toggle
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption('Info', !showChatbot),
          _toggleOption('ChatBot', showChatbot),
        ],
      ),
    );
  }

  Widget _toggleOption(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showChatbot = (title == 'ChatBot');
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.blue : Colors.transparent, // Highlight color
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black, // Text color
            fontWeight: FontWeight.bold,
          ),
        ),
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
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildChatMessage(
                messages[index]['message'],
                isBot: messages[index]['isBot'],
              );
            },
          ),
        ),
        _buildTextInputField(),
      ],
    );
  }

  Widget _buildChatMessage(String message, {bool isBot = false}) {
    return ListTile(
      leading: isBot ? Icon(Icons.android) : null,
      title: Text(
        message,
        style: TextStyle(
          color: isBot ? Colors.blue : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(isBot ? 'ChatBot' : 'You'),
    );
  }

  Widget _buildTextInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: "Type your message here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          _isLoading
              ? SizedBox(
                  height: 20.0, // Set your desired height
                  width: 20.0, // Set your desired width
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0, // Adjust the loading stroke width
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
          if (showChatbot) // Clear Chat button only in chatbot interface
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: _clearChat,
            ),
        ],
      ),
    );
  }

  void _clearChat() {
    setState(() {
      messages.clear(); // Clears messages from the UI
      _openAIService
          .clearChat(); // Optionally clear chat on the server or reset session
    });
  }

  void _sendMessage() async {
    final message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        messages.add({"message": message, "isBot": false});
        _isLoading = true; // Start loading
      });
      _textEditingController.clear();

      try {
        final response = await _openAIService.sendMessage(message);
        setState(() {
          messages.add({"message": response, "isBot": true});
        });
      } catch (e) {
        // Handle error or show an error message if necessary
        print("Failed to send message: $e");
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }
}
