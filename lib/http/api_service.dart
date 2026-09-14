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

static Future<bool?> verifyRawCoordinates(
  String charName,
  List<StrokeData> strokes,
) async {
  final url = Uri.parse('$baseUrl/verify');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'charName': charName,
        'strokes': strokes.map((s) => s.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return response.body == 'true'; // Spring이 Boolean을 그대로 내려줌 ("true"/"false")
    } else {
      print('verify 실패: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('verify 연결 실패: $e');
    return null;
  }
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

  static Future<Map<String, dynamic>?> checkBadWriting(
  String charName,
  List<StrokeData> strokes,
) async {
  final url = Uri.parse('http://172.20.10.5:8000/predict');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'charName': charName,
        'strokes': strokes.map((s) => s.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('FastAPI 오류: ${response.statusCode}');
      print(response.body);
      return null;
    }
  } catch (e) {
    print('FastAPI 연결 실패: $e');
    return null;
  }
}

}



//앤그록