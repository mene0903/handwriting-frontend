import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/drawing_canvas.dart';
import '../models/handwriting_model.dart';
import '../services/normalization_service.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey<DrawingCanvasState>();

  // 💡 중복을 줄이기 위한 공통 팝업 함수
  void _showJsonDialog(String title, String jsonString) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 600,
            height: 500,
            child: SingleChildScrollView(
              child: SelectableText(jsonString),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('닫기')
            )
          ],
        );
      },
    );
  }

  // 1. 원본 데이터 (정규화 전) 보여주기
  void _showRawData() {
    final strokes = _canvasKey.currentState?.getValidPoints();
    if (strokes != null && strokes.isNotEmpty) {
      final request = HandwritingRequest(charName: "가", strokes: strokes);
      const encoder = JsonEncoder.withIndent('  ');
      String rawJson = encoder.convert(request.toJson());
      
      _showJsonDialog('원본 JSON 데이터 (정규화 전)', rawJson);
    } else {
      _showEmptyWarning();
    }
  }

  // 2. 정규화 데이터 (서버 전송용) 보여주기
  void _showNormalizedData() {
    final strokes = _canvasKey.currentState?.getValidPoints();
    if (strokes != null && strokes.isNotEmpty) {
      // NormalizationService에서 만들어준 JSON 문자열 가져오기
      String normalizedJsonString = NormalizationService.processAndToJson("가", strokes);
      
      // 보기 예쁘게 들여쓰기(Indent)를 넣기 위해 한 번 파싱했다가 다시 인코딩
      final Map<String, dynamic> parsedJson = jsonDecode(normalizedJsonString);
      const encoder = JsonEncoder.withIndent('  ');
      String prettyNormalizedJson = encoder.convert(parsedJson);

      _showJsonDialog('정규화 JSON 데이터 (서버 전송용)', prettyNormalizedJson);
    } else {
      _showEmptyWarning();
    }
  }

  void _showEmptyWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('먼저 글자를 입력해주세요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('데이터 확인 테스트')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DrawingCanvas(key: _canvasKey, size: 400),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _canvasKey.currentState?.clearPoints(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('초기화', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _showRawData, 
                  child: const Text('원본 JSON'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _showNormalizedData, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text('정규화 JSON', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}