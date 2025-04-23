import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotService {
  static const _chatKey = 'tervy_messages_context';

  // ⚠️ PENTING: Ganti dengan API key terbaru dari OpenRouter
  static const _apiKey = 'API Key Disini';

  static Future<String> getChatResponse(
    String message,
    List<Map<String, String>> history,
  ) async {
    // Variasi referer untuk debugging
    final referers = [
      'tervy-mobile',
      'localhost',
      'tervy.app',
      'nutrition-app'
    ];

    // Daftar model dengan prioritas
    final models = [
      'mistralai/mistral-small-3.1-24b-instruct:free',
      'anthropic/claude-2.1',
      'openai/gpt-3.5-turbo'
    ];

    for (final referer in referers) {
      for (final model in models) {
        final result = await _attemptChatResponse(message, history,
            referer: referer, model: model);

        // Jika respons berhasil, kembalikan
        if (result.isNotEmpty && !result.contains('Akses ditolak')) {
          return result;
        }
      }
    }

    // Pesan default jika semua percobaan gagal
    return "⚠️ Maaf, layanan chatbot sedang mengalami gangguan. Silakan coba lagi nanti.";
  }

  static Future<String> _attemptChatResponse(
    String message,
    List<Map<String, String>> history, {
    required String referer,
    required String model,
  }) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final messages = [
      {
        'role': 'system',
        'content':
            'Kamu adalah Tervy, asisten nutrisi cerdas dalam Bahasa Indonesia. Berikan informasi nutrisi secara akurat dan ringkas. Untuk setiap makanan, berikan estimasi kalori, protein, lemak, dan karbohidrat dalam pembulatan bilangan bulat.'
      },
      ...history,
      {'role': 'user', 'content': message},
    ];

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'HTTP-Referer': referer,
      'X-Title': 'Tervy Nutrition App',
      // Tambahan headers debugging
      'X-Debug-Referer': referer,
      'X-Debug-Model': model,
    };

    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': 0.5,
      'max_tokens': 300,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Logging komprehensif
      _logDetailedResponse(response, referer, model);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _extractResponseContent(data);
      } else {
        print('❌ Request Failed: ${response.statusCode}');
        return "Error: ${response.statusCode} dengan model $model";
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return "Kesalahan jaringan dengan model $model";
    }
  }

  static void _logDetailedResponse(
      http.Response response, String referer, String model) {
    print('🌐 Referer Dicoba: $referer');
    print('🤖 Model Dicoba: $model');
    print('📡 Status Code: ${response.statusCode}');
    print('📦 Response Headers: ${response.headers}');
    print('📄 Response Body: ${response.body}');
  }

  static String _extractResponseContent(Map<dynamic, dynamic> data) {
    try {
      final content = data['choices'][0]['message']?['content'] ??
          data['choices'][0]['text'] ??
          "";

      // Bersihkan dan decode konten
      return _cleanContent(content);
    } catch (e) {
      print('❌ Gagal ekstrak konten: $e');
      return "";
    }
  }

  static String _cleanContent(String content) {
    // Hapus karakter aneh, trimming
    return content.trim().replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');
  }

  // Metode riwayat percakapan tetap sama
  static Future<void> saveConversationHistory(
      List<Map<String, String>> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatKey, jsonEncode(history));
  }

  static Future<List<Map<String, String>>> loadConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_chatKey);

    if (historyJson != null) {
      try {
        final List<dynamic> parsed = jsonDecode(historyJson);
        return parsed.map((e) => Map<String, String>.from(e)).toList();
      } catch (e) {
        print('❌ Gagal memuat riwayat: $e');
        return [];
      }
    }
    return [];
  }
}
