import 'dart:convert';
import 'package:handwriting_front/core/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/handwriting_model.dart';

class ApiService {
  static final String baseUrl = '${ApiConfig.baseUrl}/handwriting';

  static Future<bool> saveHandwriting(
    String charName,
    List<StrokeData> strokes,
  ) async {
    final url = Uri.parse('$baseUrl/save');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'charName': charName,
        'strokes': strokes.map((s) => s.toJson()).toList(),
      }),
    );

    return response.statusCode == 200;
  }

  static Future<List<StrokeData>?> getLatestHandwriting() async {
    final url = Uri.parse('$baseUrl/latest');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => StrokeData.fromJson(json)).toList();
    }

    return null;
  }

  // ㄲ 생성 요청
  static Future<bool> saveDoubleConsonant() async {
    final url = Uri.parse('$baseUrl/double/save');
    final response = await http.post(url);

    return response.statusCode == 200;
  }

  // ㄲ 불러오기
  static Future<List<StrokeData>?> getDoubleConsonant() async {
    final url = Uri.parse('$baseUrl/double');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => StrokeData.fromJson(json)).toList();
    }

    return null;
  }
}