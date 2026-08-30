import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/discovery/models/discovery_backend_result.dart';
import '../constants/app_constants.dart';
import '../../shared/models/message.dart';

class DiscoveryService {
  final http.Client _client;

  DiscoveryService({http.Client? client}) : _client = client ?? http.Client();

  Future<DiscoveryBackendResult> processIdea(String idea, List<ChatMessage> history) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/discovery/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idea': idea,
          'previousHistory': history.map((m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.content,
          }).toList(),
        }),
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        return DiscoveryBackendResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to process idea: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
