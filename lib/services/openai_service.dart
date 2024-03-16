import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _baseUrl = 'https://rocky-mesa-08596-b028720f5b6e.herokuapp.com';
  String? _sessionId;

  Future<String> sendMessage(String message) async {
    final url = Uri.parse('$_baseUrl/ask');
    final body = jsonEncode({
      'question': message,
      if (_sessionId != null) 'session_id': _sessionId,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _sessionId = data['session_id'];
      return data['response'];
    } else {
      return "Sorry, I couldn't understand that.";
    }
  }

  Future<bool> clearChat() async {
    if (_sessionId == null) return false;
    final url = Uri.parse('$_baseUrl/clear_chat');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'session_id': _sessionId}),
    );
    if (response.statusCode == 200) {
      _sessionId = null;
      return true;
    } else {
      return false;
    }
  }
}
