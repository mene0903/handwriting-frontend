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