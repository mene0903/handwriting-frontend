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

import 'dart:convert';
import '../models/handwriting_model.dart'; // PointData, StrokeData가 있는 곳

class NormalizationService {
  // 파라미터를 List<StrokeData>로 변경하여 모델과 일치시킴
  static String processAndToJson(String label, List<StrokeData> strokes) {
    if (strokes.isEmpty) return "";

    // 1. 정규화를 위한 전체 범위(min/max) 찾기
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

    // 2. 정규화 적용된 새로운 Stroke 리스트 생성
    List<Map<String, dynamic>> normalizedStrokes = strokes.map((stroke) {
      return {
        'points': stroke.points.map((p) => {
          'x': double.parse(((p.x - minX) / width).toStringAsFixed(4)),
          'y': double.parse(((p.y - minY) / height).toStringAsFixed(4)),
          'p': double.parse(p.pressure.toStringAsFixed(4)),
        }).toList()
      };
    }).toList();

    // 3. 최종 JSON 생성
    Map<String, dynamic> finalData = {
      'label': label,
      'strokes': normalizedStrokes,
    };

    return jsonEncode(finalData);
  }
}
