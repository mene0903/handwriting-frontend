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

  void loadStrokes(List<StrokeData> fetchedStrokes) {
    setState(() {
      _strokes.clear(); // 기존에 그려진 그림을 싹 지우고
      _currentStrokePoints.clear();
      _strokes.addAll(fetchedStrokes); // 서버에서 온 그림으로 덮어씁니다!
    });
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
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round // 끝을 둥글게
      ..strokeJoin = StrokeJoin.round // 꺾이는 부분도 둥글게
      ..strokeWidth = 4.0 // 선 두께 (원하시는 대로 조절)
      ..style = PaintingStyle.stroke;

    // 1. 이미 완성된 획들 그리기
    for (var stroke in strokes) {
      _drawSmoothCurve(canvas, stroke.points, paint);
    }

    // 2. 지금 실시간으로 그리고 있는 획 그리기
    if (currentStrokePoints.isNotEmpty) {
      _drawSmoothCurve(canvas, currentStrokePoints, paint);
    }
  }

  // 🚀 부드러운 곡선을 만들어주는 핵심 마법 함수
  void _drawSmoothCurve(Canvas canvas, List<PointData> points, Paint paint) {
    if (points.isEmpty) return;

    Path path = Path();
    path.moveTo(points.first.x, points.first.y);

    if (points.length == 1) {
      // 점이 하나면 그냥 점을 하나 찍습니다.
      path.lineTo(points.first.x, points.first.y);
    } else {
      // 점이 여러 개면 베지어 곡선으로 이어줍니다.
      for (int i = 0; i < points.length - 1; i++) {
        final currentPoint = points[i];
        final nextPoint = points[i + 1];

        // 두 점의 정확히 중간 지점을 계산합니다.
        final midPointX = (currentPoint.x + nextPoint.x) / 2;
        final midPointY = (currentPoint.y + nextPoint.y) / 2;

        // 현재 점을 제어점(자석)으로, 중간 지점을 도착점으로 삼아 둥글게 깎아 그립니다.
        path.quadraticBezierTo(
          currentPoint.x, currentPoint.y, 
          midPointX, midPointY
        );
      }
      // 마지막 꼬리 부분은 끝점까지 확실하게 이어줍니다.
      path.lineTo(points.last.x, points.last.y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}