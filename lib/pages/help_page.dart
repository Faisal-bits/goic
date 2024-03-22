import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import 'package:logging/logging.dart';
import 'package:goic/localization.dart';

final Logger logger = Logger('HelpPage');

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool showChatbot = false;
  final TextEditingController _textEditingController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final OpenAIService _openAIService = OpenAIService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.help ?? 'Help'),
        actions: [
          _customToggle(),
        ],
      ),
      body: showChatbot ? _chatbotInterface() : _infoPage(),
    );
  }

  Widget _customToggle() {
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background of the toggle
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption(localizations?.info ?? 'Info', !showChatbot),
          _toggleOption(localizations?.chatBot ?? 'ChatBot', showChatbot),
        ],
      ),
    );
  }

  Widget _toggleOption(String title, bool isSelected) {
    final localizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          // Update the condition to check against the localized string
          showChatbot = (title == localizations?.chatBot);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
    final localizations = AppLocalizations.of(context);
    return ListView(
      children: <Widget>[
        _buildExpansionTile(localizations?.whatIsThisApp ?? "What is this app?",
            localizations?.appExplanation ?? "This app is..."),
        _buildExpansionTile(localizations?.howDoIUseIt ?? "How do I use it?",
            localizations?.usageInstructions ?? "You can use it by..."),
        _buildExpansionTile(localizations?.whatIsGID ?? "What is GID?",
            localizations?.gidExplanation ?? "GID stands for..."),
        // More QnA questions as needed
      ],
    );
  }

  Widget _buildExpansionTile(String title, String answer) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      leading: isBot ? const Icon(Icons.android) : null,
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
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: localizations?.typeYourMessageHere ??
                    "Type your message here...",
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.only(
                      left: 10), // Add padding when the loading icon is visible
                  child: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
          if (showChatbot) // This ensures the button is shown only in the chatbot interface
            IconButton(
              icon: const Icon(Icons.delete_outline),
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
          .clearChat(); // clear chat on the server or reset session as well
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
        logger.warning("Failed to send message: $e");
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }
}
