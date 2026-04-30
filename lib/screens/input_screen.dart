import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:handwriting_front/http/api_service.dart';
import '../widgets/drawing_canvas.dart';
import '../models/handwriting_model.dart';
import '../services/normalization_service.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final GlobalKey<DrawingCanvasState> _originalCanvasKey = GlobalKey<DrawingCanvasState>();
  final GlobalKey<DrawingCanvasState> _serverCanvasKey = GlobalKey<DrawingCanvasState>();
  
  // 💡 캔버스 크기를 말씀하신 대로 여유로운 150으로 확 줄였습니다!
  // 나중에 더 키우거나 줄이고 싶으시면 이 숫자만 180, 200 등으로 바꾸시면 됩니다.
  final double canvasSize = 250.0;

  void _saveToServer() async {
    final strokes = _originalCanvasKey.currentState?.getValidPoints();
    if (strokes != null && strokes.isNotEmpty) {
      List<StrokeData> normalizedStrokes = NormalizationService.normalizeStrokes(strokes);
      bool isSuccess = await ApiService.saveHandwriting("가", normalizedStrokes);

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 서버(DB)에 성공적으로 저장되었습니다!')),
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

// 🚀 서버 불러오기 & 양쪽 캔버스 완벽 보정 비교
  void _loadFromServer() async {
    List<StrokeData>? fetchedStrokes = await ApiService.getLatestHandwriting();

    if (fetchedStrokes != null && fetchedStrokes.isNotEmpty) {
      // 💡 1. 사각형의 딱 절반 크기(50%)로 배율 설정, 중앙 여백(Offset) 계산
      final double targetScale = canvasSize * 0.5; 
      final double offset = (canvasSize - targetScale) / 2;

      // --- [오른쪽: 서버 데이터 렌더링] ---
      List<StrokeData> denormalizedServer = fetchedStrokes.map((stroke) {
        return StrokeData(
          points: stroke.points.map((p) => PointData(
            x: (p.x * targetScale) + offset, 
            y: (p.y * targetScale) + offset, 
            pressure: p.pressure,
          )).toList(),
        );
      }).toList();
      _serverCanvasKey.currentState?.loadStrokes(denormalizedServer);

      // --- [왼쪽: 원본 데이터 보정 렌더링] ---
      final rawStrokes = _originalCanvasKey.currentState?.getValidPoints();
      // 왼쪽에 사용자가 그린 그림이 남아있다면 똑같이 보정해줍니다.
      if (rawStrokes != null && rawStrokes.isNotEmpty) {
        // 사용자의 날것(Raw) 데이터를 서버와 똑같은 조건(0.0~1.0)으로 먼저 정규화
        List<StrokeData> normalizedOriginal = NormalizationService.normalizeStrokes(rawStrokes);
        
        // 정규화된 데이터를 50% 스케일 + 정중앙으로 역정규화
        List<StrokeData> correctedOriginal = normalizedOriginal.map((stroke) {
          return StrokeData(
            points: stroke.points.map((p) => PointData(
              x: (p.x * targetScale) + offset, 
              y: (p.y * targetScale) + offset, 
              pressure: p.pressure,
            )).toList(),
          );
        }).toList();
        
        // 원본 캔버스(왼쪽)를 보정된 데이터로 덮어쓰기!
        _originalCanvasKey.currentState?.loadStrokes(correctedOriginal);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📥 양쪽 모두 50% 정중앙 보정 완료! 완벽한 비교가 가능합니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 불러올 데이터가 없거나 실패했습니다.')),
      );
    }
  }

  void _showEmptyWarning() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('먼저 왼쪽 캔버스에 글자를 입력해주세요.')),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('원본 vs 서버 데이터 확실한 비교')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // 💡 작아진 캔버스 두 개를 나란히 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 왼쪽: 원본 영역
                Column(
                  children: [
                    const Text("[ 원본 ]", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    DrawingCanvas(key: _originalCanvasKey, size: canvasSize),
                  ],
                ),
                const SizedBox(width: 30), // 캔버스가 작아진 만큼 가운데 여백을 살짝 늘렸습니다.
                // 오른쪽: 서버 결과 영역
                Column(
                  children: [
                    const Text("[ 서버 데이터 ]", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                    const SizedBox(height: 10),
                    DrawingCanvas(key: _serverCanvasKey, size: canvasSize),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            // 하단 제어 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  child: const Text('둘 다 초기화', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveToServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text('서버에 저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loadFromServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text('불러와서 비교', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}