import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 본인의 PC IP 주소 또는 localhost를 입력하세요. (에뮬레이터는 10.0.2.2)
  static const String baseUrl = 'http://localhost:8080/api/handwriting';

  // 1. 저장하기 (POST)
  static Future<bool> saveHandwriting(String charName, List<StrokeData> strokes) async {
    final url = Uri.parse('$baseUrl/save');
    
    // StrokeData 리스트를 Map 리스트로 변환 (toJson 메서드가 있다고 가정)
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
      // JSON 문자열을 List<dynamic>으로 변환 후 다시 List<StrokeData>로 조립
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => StrokeData.fromJson(json)).toList();
    } else {
      print('불러오기 실패: ${response.statusCode}');
      return null;
    }
  }
}