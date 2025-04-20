import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotService {
  static const _chatKey = 'tervy_messages_context';

  static Future<String> getChatResponse(
    String message,
    List<Map<String, String>> history,
  ) async {
    const apiKey =
        'Api Key di sini';

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
      'X-Title': 'Tervy Nutrition Chatbot',
    };

    final body = jsonEncode({
      'model': 'mistralai/mistral-small-3.1-24b-instruct:free',
      'messages': messages,
      'temperature': 0.5,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']?['content'] ??
            data['choices'][0]['text'] ??
            "Tidak ada respons dari model.";
        return content;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return "Akses ditolak. Pastikan API key benar dan tidak melebihi batas penggunaan.";
      } else {
        return "Maaf, ada kendala (kode ${response.statusCode}). Coba lagi nanti.";
      }
    } catch (e) {
      print('❌ Network error: $e');
      return "Terjadi kesalahan jaringan. Pastikan koneksi internet kamu stabil.";
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
