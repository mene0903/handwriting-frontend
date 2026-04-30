import 'dart:convert';
import 'package:handwriting_front/core/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/handwriting_model.dart'; // 모델 import

class ApiService {
  // ApiConfig의 설정값을 가져와서 최종 URL을 만듭니다.
  static final String baseUrl = '${ApiConfig.baseUrl}/handwriting';

  // 1. 저장하기 (POST)
  static Future<bool> saveHandwriting(String charName, List<StrokeData> strokes) async {
    final url = Uri.parse('$baseUrl/save');
    
    final strokesJson = strokes.map((s) => s.toJson()).toList();

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'charName': charName,
        'strokes': strokesJson,
      }),
    );

    if (response.statusCode == 200) {
      print('서버 저장 성공!');
      return true;
    } else {
      print('저장 실패: ${response.statusCode}');
      return false;
    }
  }

  // 2. 불러오기 (GET)
  static Future<List<StrokeData>?> getLatestHandwriting() async {
    final url = Uri.parse('$baseUrl/latest');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      // 아까 모델에 추가한 fromJson 팩토리가 여기서 사용됩니다!
      return jsonData.map((json) => StrokeData.fromJson(json)).toList();
    } else {
      print('불러오기 실패: ${response.statusCode}');
      return null;
    }
  }
}