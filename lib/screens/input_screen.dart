import 'package:flutter/material.dart';
import '../widgets/drawing_canvas.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey<DrawingCanvasState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('손글씨 입력')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '정사각형 안에 글자를 써주세요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              DrawingCanvas(key: _canvasKey, size: 400),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _canvasKey.currentState?.clearPoints(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('지우기', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      final strokes = _canvasKey.currentState?.getValidPoints();
                      if (strokes != null && strokes.isNotEmpty) {
                        print("전송할 획 개수: ${strokes.length}");
                      }
                    },
                    child: const Text('서버 전송'),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}