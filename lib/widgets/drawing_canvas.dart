import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/handwriting_model.dart'; // PointData, StrokeData 임포트 (경로 확인 필수)

class DrawingCanvas extends StatefulWidget {
  final double size;

  const DrawingCanvas({Key? key, required this.size}) : super(key: key);

  @override
  // InputScreen에서 GlobalKey로 접근해야 하므로 State 클래스는 public(언더바 없음)이어야 합니다.
  DrawingCanvasState createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  // 1. 화면에 그려질 전체 획을 담는 리스트
  final List<StrokeData> _strokes = [];
  
  // 2. 현재 펜이 닿아있는 동안(드래그 중) 기록되는 단일 획의 점들
  List<PointData> _currentStrokePoints = [];

  // --- InputScreen에서 호출하는 외부 접근 메서드 ---

  void clearPoints() {
    setState(() {
      _strokes.clear();
      _currentStrokePoints.clear();
    });
  }

  List<StrokeData> getValidPoints() {
    // 혹시 펜을 떼지 않고 누른 상태로 전송을 누를 경우를 대비해 현재 획도 포함
    List<StrokeData> allStrokes = List.from(_strokes);
    if (_currentStrokePoints.isNotEmpty) {
      allStrokes.add(StrokeData(points: List.from(_currentStrokePoints)));
    }
    return allStrokes;
  }

  // --- 터치 및 펜 인식 이벤트 (아이패드 맞춤형) ---

  void _onPointerDown(PointerDownEvent event) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localOffset = box.globalToLocal(event.position);

    setState(() {
      _currentStrokePoints = [
        PointData(
          x: localOffset.dx,
          y: localOffset.dy,
          pressure: event.pressure, // 애플 펜슬의 필압 데이터 캡처
        )
      ];
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localOffset = box.globalToLocal(event.position);

    // 캔버스(정사각형) 영역 밖으로 삐져나가는 선은 무시하도록 안전장치 추가
    if (localOffset.dx >= 0 && localOffset.dx <= widget.size &&
        localOffset.dy >= 0 && localOffset.dy <= widget.size) {
      setState(() {
        _currentStrokePoints.add(
          PointData(
            x: localOffset.dx,
            y: localOffset.dy,
            pressure: event.pressure,
          )
        );
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      if (_currentStrokePoints.isNotEmpty) {
        _strokes.add(StrokeData(points: List.from(_currentStrokePoints)));
        _currentStrokePoints = []; // 다음 획을 위해 리셋
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2), // 정사각형 가이드라인
        color: Colors.white,
      ),
      // GestureDetector 대신 Listener를 사용해야 원시 필압(Pressure) 데이터를 손실 없이 받습니다.
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: CustomPaint(
          painter: DrawingPainter(_strokes, _currentStrokePoints),
          size: Size(widget.size, widget.size),
        ),
      ),
    );
  }
}

// --- 캔버스에 선을 렌더링하는 클래스 ---
class DrawingPainter extends CustomPainter {
  final List<StrokeData> strokes;
  final List<PointData> currentStrokePoints;

  DrawingPainter(this.strokes, this.currentStrokePoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // 1. 이미 완료된 획 렌더링
    for (var stroke in strokes) {
      _drawStroke(canvas, stroke.points, paint);
    }

    // 2. 현재 펜이 움직이고 있는 획 실시간 렌더링
    if (currentStrokePoints.isNotEmpty) {
      _drawStroke(canvas, currentStrokePoints, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<PointData> points, Paint paint) {
    if (points.isEmpty) return;
    
    // 점을 하나만 '콕' 찍었을 경우
    if (points.length == 1) {
      paint.strokeWidth = (points.first.pressure * 5) + 2; 
      canvas.drawPoints(PointMode.points, [Offset(points.first.x, points.first.y)], paint);
      return;
    }

    // 선 그리기 (필압에 따라 선의 굵기가 미세하게 변함)
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // 기본 굵기(2)에 필압 가중치를 더해줍니다. 마우스/손가락일 경우 기본 굵기로 그려집니다.
      paint.strokeWidth = (p1.pressure > 0 ? p1.pressure * 5 : 3) + 2;

      canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true; // 터치할 때마다 즉시 갱신되어야 하므로 true
  }
}