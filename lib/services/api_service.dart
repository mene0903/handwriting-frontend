import 'package:http/http.dart' as http;
import 'package:handwriting_front/core/api_config.dart';

class ApiService {
  Future<bool> sendHandwritingJson(String jsonBody) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/handwriting/save'),
        headers: {"Content-Type": "application/json"},
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        print("서버 저장 성공!");
        return true;
      } else {
        print("서버 에러: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("통신 중 에러 발생: $e");
      return false;
    }
  }
}