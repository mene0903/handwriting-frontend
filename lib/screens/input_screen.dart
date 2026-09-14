import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:handwriting_front/http/api_service.dart';
import '../widgets/drawing_canvas.dart';
import '../models/handwriting_model.dart';
import '../services/normalization_service.dart';
import 'bad_writing_test_screen.dart';
import 'double_jamo_test_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);

  @override
  State<InputScreen> createState() => _InputScreenState();
}



class _InputScreenState extends State<InputScreen> {
  final GlobalKey<DrawingCanvasState> _originalCanvasKey =
      GlobalKey<DrawingCanvasState>();

  final GlobalKey<DrawingCanvasState> _serverCanvasKey =
      GlobalKey<DrawingCanvasState>();

  final double canvasSize = 250.0;

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
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _showRawData() {
    final strokes = _originalCanvasKey.currentState?.getValidPoints();

    if (strokes != null && strokes.isNotEmpty) {
      final request = HandwritingRequest(
        charName: "ㄱ",
        strokes: strokes,
      );

      const encoder = JsonEncoder.withIndent('  ');
      final rawJson = encoder.convert(request.toJson());

      _showJsonDialog('원본 JSON 데이터', rawJson);
    } else {
      _showEmptyWarning();
    }
  }

  void _showNormalizedData() {
    final strokes = _originalCanvasKey.currentState?.getValidPoints();

    if (strokes != null && strokes.isNotEmpty) {
      final normalizedStrokes =
          NormalizationService.normalizeStrokes(strokes);

      final request = HandwritingRequest(
        charName: "ㄱ",
        strokes: normalizedStrokes,
      );

      const encoder = JsonEncoder.withIndent('  ');
      final normalizedJson = encoder.convert(request.toJson());

      _showJsonDialog('정규화 JSON 데이터 테스트용', normalizedJson);
    } else {
      _showEmptyWarning();
    }
  }

  void _saveToServer() async {
    final strokes = _originalCanvasKey.currentState?.getValidPoints();

    if (strokes != null && strokes.isNotEmpty) {
      final isSuccess = await ApiService.saveHandwriting("ㄱ", strokes);

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 원본 좌표가 서버로 전송되었습니다!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 저장 실패... 서버 상태를 확인해주세요.')),
        );
      }
    } else {
      _showEmptyWarning();
    }
  }

  void _loadFromServer() async {
    final fetchedStrokes = await ApiService.getLatestHandwriting();

    if (fetchedStrokes != null && fetchedStrokes.isNotEmpty) {
      _drawNormalizedStrokesOnServerCanvas(fetchedStrokes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📥 서버 데이터 불러오기 완료')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 불러올 데이터가 없거나 실패했습니다.')),
      );
    }
  }

  void _saveDoubleConsonant() async {
    final isSuccess = await ApiService.saveDoubleConsonant();

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 ㄲ 생성 및 저장 성공!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ㄲ 저장 실패')),
      );
    }
  }
  
void _drawNormalizedStrokesOnOriginalCanvas(List<StrokeData> strokes) {
  final double targetScale = canvasSize * 0.5;
  final double offset = (canvasSize - targetScale) / 2;

  final denormalized = strokes.map((stroke) {
    return StrokeData(
      points: stroke.points.map((p) {
        return PointData(
          x: (p.x * targetScale) + offset,
          y: (p.y * targetScale) + offset,
          pressure: p.pressure,
        );
      }).toList(),
    );
  }).toList();

  _originalCanvasKey.currentState?.loadStrokes(denormalized);
}
  
void _loadDoubleConsonant() async {
  final doubleConsonant = await ApiService.getDoubleConsonant();
  final latestConsonant = await ApiService.getLatestHandwriting();

  if (doubleConsonant != null &&
      doubleConsonant.isNotEmpty &&
      latestConsonant != null &&
      latestConsonant.isNotEmpty) {
    
    // 왼쪽 원본 캔버스에는 ㄱ
    _drawNormalizedStrokesOnOriginalCanvas(latestConsonant);

    // 오른쪽 서버 캔버스에는 ㄲ
    _drawNormalizedStrokesOnServerCanvas(doubleConsonant);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📥 왼쪽 ㄱ / 오른쪽 ㄲ 비교 완료')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ ㄱ 또는 ㄲ 데이터가 없습니다.')),
    );
  }
}
  void _drawNormalizedStrokesOnServerCanvas(List<StrokeData> strokes) {
    final double targetScale = canvasSize * 0.5;
    final double offset = (canvasSize - targetScale) / 2;

    final denormalized = strokes.map((stroke) {
      return StrokeData(
        points: stroke.points.map((p) {
          return PointData(
            x: (p.x * targetScale) + offset,
            y: (p.y * targetScale) + offset,
            pressure: p.pressure,
          );
        }).toList(),
      );
    }).toList();

    _serverCanvasKey.currentState?.loadStrokes(denormalized);
  }

  void _showEmptyWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('먼저 왼쪽 캔버스에 글자를 입력해주세요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('원본 서버 데이터 비교'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      "[ 원본 ]",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DrawingCanvas(
                      key: _originalCanvasKey,
                      size: canvasSize,
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    const Text(
                      "[ 서버 데이터 ]",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DrawingCanvas(
                      key: _serverCanvasKey,
                      size: canvasSize,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _showRawData,
                  icon: const Icon(Icons.code),
                  label: const Text('원본 JSON'),
                ),
                const SizedBox(width: 15),
                OutlinedButton.icon(
                  onPressed: _showNormalizedData,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('정규화 JSON 테스트'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _originalCanvasKey.currentState?.clearPoints();
                    _serverCanvasKey.currentState?.clearPoints();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text(
                    '둘 다 초기화',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: _saveToServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text(
                    'ㄱ 저장',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: _loadFromServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text(
                    'ㄱ 불러오기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: _saveDoubleConsonant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text(
                    'ㄲ 저장',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: _loadDoubleConsonant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text(
                    'ㄲ 불러오기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BadWritingTestScreen(),
      ),
    ); 
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    minimumSize: const Size(100, 45), 
  ),
  child: const Text(
    '악필 검증 테스트',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoubleJamoTestScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text(
                    '쌍자음 합성 테스트',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}