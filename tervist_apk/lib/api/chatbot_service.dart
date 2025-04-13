import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';

class ChatbotService {
  static const _chatKey = 'tervy_messages_context';

  static Future<String> getChatGPTResponse(
      String message, List<Map<String, String>> history) async {
    final apiKey =
        "API-KEY-DISININ";
    final messages = [
      {
        'role': 'system',
        'content':
            'Kamu adalah Tervy, asisten nutrisi cerdas dan ramah. Selalu balas dalam Bahasa Indonesia. Jika pengguna menyebut makanan (misal: pisang, ayam goreng, nasi uduk, cokelat), berikan estimasi kandungan kalori, protein, lemak, dan karbohidrat per takaran yang disebutkan. Jika pengguna menulis "saya makan 3 ayam goreng", langsung berikan estimasi nutrisinya (contoh: 3 ayam goreng = 600 kalori, 45g protein, dll). Balasan harus langsung ke poin, ringkas, jelas, dan tidak mengulang pertanyaan.'
      },
      ...history,
      {'role': 'user', 'content': message},
    ];

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'HTTP-Referer': 'https://tervyapp', // optional referer
      'X-Title': 'Tervy Nutrition Chatbot',
    };
    final body = jsonEncode({
      'model': 'openai/gpt-3.5-turbo',
      'messages': messages,
      'temperature': 0.5,
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('OpenRouter API error: ${response.statusCode} - ${response.body}');
      return "Maaf, aku mengalami kendala. Silakan coba lagi nanti.";
    }
  }

  static Future<void> saveConversationHistory(
      List<Map<String, String>> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatKey, jsonEncode(history));
  }

  static Future<List<Map<String, String>>> loadConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_chatKey);
    if (historyJson != null) {
      final List<dynamic> parsed = jsonDecode(historyJson);
      return parsed.map((e) => Map<String, String>.from(e)).toList();
    }
    return [];
  }
}
