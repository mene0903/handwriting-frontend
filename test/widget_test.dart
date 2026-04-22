import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp()); // 여기서 MyApp을 호출함

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: ApiTestButton()),
      ),
    );
  }
}

class ApiTestButton extends StatefulWidget {
  const ApiTestButton({super.key});

  @override
  State<ApiTestButton> createState() => _ApiTestButtonState();
}

class _ApiTestButtonState extends State<ApiTestButton> {
  String _message = "버튼을 눌러 서버와 통신하세요";

  Future<void> _callApi() async {
    try {
      // 본인 PC의 IPv4 주소로 꼭 수정하세요!
      final url = Uri.parse("http://10.0.2.2:8080/api/test"); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() => _message = "서버 응답: ${response.body}");
      } else {
        setState(() => _message = "에러: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _message = "연결 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_message, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _callApi, child: const Text("서버 요청 보내기")),
      ],
    );
  }
}