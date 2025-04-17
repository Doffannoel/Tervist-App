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
        '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';

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
      'HTTP-Referer': 'https://tervy.vercel.app', // ganti sesuai domain kamu
      'X-Title': 'Tervy Nutrition Chatbot',
    };

    final body = jsonEncode({
      'model': 'mistralai/mistral-7b-instruct',
      'messages': messages,
      'temperature': 0.5,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      print("📡 Status Code: ${response.statusCode}");
      print("📦 Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'];

        if (choices != null && choices.isNotEmpty) {
          final choice = choices[0];

          if (choice.containsKey('message') &&
              choice['message'].containsKey('content')) {
            return choice['message']['content'];
          } else if (choice.containsKey('text')) {
            return choice['text'];
          } else {
            return "Model tidak memberikan jawaban. Coba ganti pertanyaan.";
          }
        } else {
          return "Tidak ada respons dari model. Coba beberapa saat lagi.";
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return "Akses ditolak. Cek API key, Referer URL, dan saldo akun kamu.";
      } else {
        return "Error ${response.statusCode}: ${response.reasonPhrase}";
      }
    } catch (e) {
      print("❌ Network error: $e");
      return "Terjadi kesalahan jaringan. Coba lagi nanti ya.";
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
