import 'package:flutter/material.dart';

import '../widgets/drawing_canvas.dart';
import '../http/api_service.dart';

class BadWritingTestScreen extends StatefulWidget {
  const BadWritingTestScreen({super.key});

  @override
  State<BadWritingTestScreen> createState() => _BadWritingTestScreenState();
}

class _BadWritingTestScreenState extends State<BadWritingTestScreen> {
  final GlobalKey<DrawingCanvasState> _canvasKey1 =
      GlobalKey<DrawingCanvasState>();

  final double canvasSize = 250.0;

  Map<String, dynamic>? result1;

  bool isLoading = false;

  String selectedChar = "ㄱ";

  final List<String> jamoList = [
    "ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ",
    "ㅏ", "ㅐ", "ㅑ", "ㅓ", "ㅔ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ",
  ];

  Future<void> _checkBadWriting() async {
    final strokes1 = _canvasKey1.currentState?.getValidPoints();

    if (strokes1 == null || strokes1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글자를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      result1 = null;
    });

    try {
      final response1 =
          await ApiService.checkBadWriting(selectedChar, strokes1);

      setState(() {
        result1 = response1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검증 중 오류 발생: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 스프링(/verify)으로 원본 좌표를 보내는 테스트 버튼
  // 지금은 받은 좌표를 확인만 하는 단계. 나머지(FastAPI 호출, 저장/실패 분기)는
  // Spring 쪽에서 이어서 구현 예정.
Future<void> _sendToSpring() async {
  final strokes1 = _canvasKey1.currentState?.getValidPoints();

  if (strokes1 == null || strokes1.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('글자를 입력해주세요.')),
    );
    return;
  }

  setState(() { isLoading = true; });

  try {
    final passed = await ApiService.verifyRawCoordinates(selectedChar, strokes1);

    if (passed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 스프링 전송 실패... 서버 상태를 확인해주세요.')),
      );
    } else if (passed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 통과! DB에 저장되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✋ 검증 실패. 다시 써주세요.')),
      );
    }
  } finally {
    setState(() { isLoading = false; });
  }
}
  void _clearCanvas() {
    _canvasKey1.currentState?.clearPoints();

    setState(() {
      result1 = null;
    });
  }

  Widget _buildJamoSelector() {
    return Column(
      children: [
        const Text(
          '검증할 자음/모음 선택',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '선택한 글자를 쓴 뒤 악필 검증을 누르세요.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: jamoList.map((char) {
            final bool isSelected = selectedChar == char;

            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        selectedChar = char;
                        result1 = null;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? Colors.black : Colors.grey.shade300,
                foregroundColor: isSelected ? Colors.white : Colors.black,
                minimumSize: const Size(48, 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              child: Text(
                char,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Text(
          '현재 선택한 글자: $selectedChar',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildWritingBox({
    required String title,
    required GlobalKey<DrawingCanvasState> canvasKey,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        DrawingCanvas(
          key: canvasKey,
          size: canvasSize,
        ),
      ],
    );
  }

  Widget _buildSimpleResult({
    required String title,
    required Map<String, dynamic>? result,
  }) {
    if (result == null) {
      return const SizedBox.shrink();
    }

    final selected =
        result["selectedChar"]?.toString() ??
        result["선택글자"]?.toString() ??
        selectedChar;

    final predicted =
        result["predictedChar"]?.toString() ??
        result["CNN예측글자"]?.toString() ??
        "-";

    final confidence =
        result["confidence"]?.toString() ??
        result["CNN정확도"]?.toString() ??
        "-";

    final similarity =
        result["similarity"]?.toString() ??
        result["코사인유사도"]?.toString() ??
        "-";

    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "선택 글자: $selected",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "CNN 예측: $predicted",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "CNN 확률: $confidence%",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "선택 글자 유사도: $similarity",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('악필 검증 테스트'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildJamoSelector(),
            const SizedBox(height: 30),
            Wrap(
              spacing: 40,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: [
                _buildWritingBox(
                  title: '1번 글자 ($selectedChar)',
                  canvasKey: _canvasKey1,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 30,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildSimpleResult(
                  title: '1번 결과',
                  result: result1,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : _clearCanvas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    '초기화',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _checkBadWriting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    isLoading ? '검증 중...' : 'FastAPI 검증',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _sendToSpring,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text(
                    isLoading ? '전송 중...' : '스프링으로 전송',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}