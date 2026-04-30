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
    'x': double.parse(x.toStringAsFixed(4)),
    'y': double.parse(y.toStringAsFixed(4)),
    'p': double.parse(pressure.toStringAsFixed(4)),
  };

  // [추가됨] 서버에서 온 JSON을 다시 PointData 객체로 변환
  factory PointData.fromJson(Map<String, dynamic> json) {
    return PointData(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      pressure: (json['p'] as num).toDouble(), // 백엔드에는 'p'로 저장됨
    );
  }
}

class StrokeData {
  List<PointData> points;
  StrokeData({required this.points});

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
  };

  // [추가됨] 서버에서 온 JSON을 다시 StrokeData 객체로 변환
  factory StrokeData.fromJson(Map<String, dynamic> json) {
    var pointsJson = json['points'] as List;
    List<PointData> pointsList = pointsJson.map((point) => PointData.fromJson(point)).toList();
    return StrokeData(points: pointsList);
  }
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