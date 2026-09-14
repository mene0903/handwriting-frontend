import '../models/handwriting_model.dart';

/// 0~1 정규화 좌표 공간 위의 사각형 영역.
/// (x, y)는 좌상단 기준, w/h는 너비/높이.
class ComposeBox {
  final double x;
  final double y;
  final double w;
  final double h;

  const ComposeBox({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  @override
  String toString() =>
      'Box(x=${x.toStringAsFixed(3)}, y=${y.toStringAsFixed(3)}, '
      'w=${w.toStringAsFixed(3)}, h=${h.toStringAsFixed(3)})';
}

/// gap/scale/baseHeight 파라미터 묶음.
/// 화면의 슬라이더 값과 1:1로 대응됨.
class DoubleJamoParams {
  final double gap;
  final double scale;
  final double baseHeight;

  const DoubleJamoParams({
    this.gap = 0.06,
    this.scale = 1.08,
    this.baseHeight = 0.85,
  });

  DoubleJamoParams copyWith({
    double? gap,
    double? scale,
    double? baseHeight,
  }) {
    return DoubleJamoParams(
      gap: gap ?? this.gap,
      scale: scale ?? this.scale,
      baseHeight: baseHeight ?? this.baseHeight,
    );
  }
}

/// gap/scale/baseHeight → leftBox/rightBox 계산 결과.
/// 왼쪽은 기본 크기, 오른쪽은 scale배 더 크게 배치한다.
class DoubleJamoLayout {
  final ComposeBox leftBox;
  final ComposeBox rightBox;

  const DoubleJamoLayout({required this.leftBox, required this.rightBox});
}

/// 쌍자음(ㄲ, ㄸ, ㅃ, ㅆ, ㅉ) 합성 로직.
///
/// 단자음(ㄱ, ㄷ, ㅂ, ㅅ, ㅈ 등)의 0~1 정규화 좌표를 그대로 복사해서
/// 좌우로 배치하되, 오른쪽 자음을 왼쪽보다 scale배 크게 그려서
/// 한글 폰트 디자인 원칙(오른쪽이 살짝 커야 균형이 맞음)을 반영한다.
///
/// 자음 종류에 의존하지 않는 순수 함수이므로 ㄱ/ㄷ/ㅂ/ㅅ/ㅈ 어디에든
/// 동일하게 적용 가능하다.
class DoubleJamoComposer {
  /// gap, scale, baseHeight로부터 leftBox/rightBox를 계산한다.
  static DoubleJamoLayout computeLayout(DoubleJamoParams params) {
    final gap = params.gap;
    final scale = params.scale;
    final baseHeight = params.baseHeight;

    final leftW = (1 - gap) / (1 + scale);
    final rightW = leftW * scale;

    final leftBox = ComposeBox(
      x: 0,
      y: 1 - baseHeight,
      w: leftW,
      h: baseHeight,
    );

    final rightBox = ComposeBox(
      x: leftW + gap,
      y: 1 - baseHeight * scale,
      w: rightW,
      h: baseHeight * scale,
    );

    return DoubleJamoLayout(leftBox: leftBox, rightBox: rightBox);
  }

  /// 원본(0~1) StrokeData 리스트를 지정된 box 범위로 리스케일(remap)한다.
  /// 원본 좌표가 이미 0~1 범위라고 가정하고, 그 범위를 box 안으로 선형 매핑한다.
  static List<StrokeData> _remapStrokes(
    List<StrokeData> original,
    ComposeBox box,
  ) {
    return original.map((stroke) {
      final remappedPoints = stroke.points.map((p) {
        return PointData(
          x: box.x + p.x * box.w,
          y: box.y + p.y * box.h,
          pressure: p.pressure,
        );
      }).toList();

      return StrokeData(points: remappedPoints);
    }).toList();
  }

  /// 단자음 원본 좌표(0~1) 하나로부터 쌍자음 좌표 리스트를 합성한다.
  /// 왼쪽/오른쪽 모두 같은 원본을 복사해서 각자의 box로 리맵한 뒤 합친다.
  static List<StrokeData> compose(
    List<StrokeData> baseStrokes,
    DoubleJamoParams params,
  ) {
    if (baseStrokes.isEmpty) return [];

    final layout = computeLayout(params);

    final leftStrokes = _remapStrokes(baseStrokes, layout.leftBox);
    final rightStrokes = _remapStrokes(baseStrokes, layout.rightBox);

    return [...leftStrokes, ...rightStrokes];
  }
}

/// 단자음 → 쌍자음 매핑. 지금은 ㄱ→ㄲ만 DB 연동이 되지만,
/// 합성 공식 자체는 자음 종류에 무관하므로 구조만 미리 확장해둔다.
class JamoPair {
  final String single;
  final String double;

  const JamoPair(this.single, this.double);
}

const List<JamoPair> kDoubleJamoPairs = [
  JamoPair('ㄱ', 'ㄲ'),
  JamoPair('ㄷ', 'ㄸ'),
  JamoPair('ㅂ', 'ㅃ'),
  JamoPair('ㅅ', 'ㅆ'),
  JamoPair('ㅈ', 'ㅉ'),
];