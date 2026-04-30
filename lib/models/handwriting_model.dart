/*class PointData {
  final double x;
  final double y;
  final double pressure;

  PointData({required this.x, required this.y, required this.pressure});

  Map<String, dynamic> toJson() => {
    'x': double.parse(x.toStringAsFixed(4)), 
    'y': double.parse(y.toStringAsFixed(4)),
    'p': double.parse(pressure.toStringAsFixed(4)),
  };
}

class StrokeData {
  List<PointData> points;
  StrokeData({required this.points});

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
  };
}

class HandwritingRequest {
  final String charName;
  final List<StrokeData> strokes;

  HandwritingRequest({required this.charName, required this.strokes});

  Map<String, dynamic> toJson() => {
    'charName': charName,
    'strokes': strokes.map((s) => s.toJson()).toList(),
  };
}
*/

class PointData {
  final double x;
  final double y;
  final double pressure;

  PointData({required this.x, required this.y, required this.pressure});

  Map<String, dynamic> toJson() => {
    'x': double.parse(x.toStringAsFixed(4)), // 소수점 4자리까지 제한 (용량 최적화)
    'y': double.parse(y.toStringAsFixed(4)),
    'p': double.parse(pressure.toStringAsFixed(4)),
  };
}

class StrokeData {
  List<PointData> points;
  StrokeData({required this.points});

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
  };
}

// 기존 PointData, StrokeData 아래에 추가
class HandwritingRequest {
  final String charName;       // 어떤 글자인지 (예: "가")
  final List<StrokeData> strokes; // 여러 개의 획들

  HandwritingRequest({required this.charName, required this.strokes});

  Map<String, dynamic> toJson() => {
    'charName': charName,
    'strokes': strokes.map((s) => s.toJson()).toList(),
  };
}