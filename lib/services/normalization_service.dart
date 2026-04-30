/*import 'dart:convert';
import '../models/handwriting_model.dart';

class NormalizationService {
  static String processAndToJson(String label, List<StrokeData> strokes) {
    if (strokes.isEmpty) return "";

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var stroke in strokes) {
      for (var p in stroke.points) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
    }

    double width = (maxX - minX) == 0 ? 1 : (maxX - minX);
    double height = (maxY - minY) == 0 ? 1 : (maxY - minY);

    List<Map<String, dynamic>> normalizedStrokes = strokes.map((stroke) {
      return {
        'points': stroke.points.map((p) => {
          'x': double.parse(((p.x - minX) / width).toStringAsFixed(4)),
          'y': double.parse(((p.y - minY) / height).toStringAsFixed(4)),
          'p': double.parse(p.pressure.toStringAsFixed(4)),
        }).toList()
      };
    }).toList();

    Map<String, dynamic> finalData = {
      'label': label,
      'strokes': normalizedStrokes,
    };

    return jsonEncode(finalData);
  }
}
*/

import '../models/handwriting_model.dart';

class NormalizationService {
  // 반환 타입을 String에서 List<StrokeData>로 변경
  static List<StrokeData> normalizeStrokes(List<StrokeData> strokes) {
    if (strokes.isEmpty) return [];

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var stroke in strokes) {
      for (var p in stroke.points) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
    }

    double width = (maxX - minX) == 0 ? 1 : (maxX - minX);
    double height = (maxY - minY) == 0 ? 1 : (maxY - minY);

    // 정규화된 좌표를 가진 새로운 StrokeData 객체 리스트 생성
    List<StrokeData> normalizedStrokes = strokes.map((stroke) {
      List<PointData> normalizedPoints = stroke.points.map((p) {
        return PointData(
          x: (p.x - minX) / width,
          y: (p.y - minY) / height,
          pressure: p.pressure, // 필압은 원본 유지
        );
      }).toList();
      
      return StrokeData(points: normalizedPoints);
    }).toList();

    return normalizedStrokes;
  }
}