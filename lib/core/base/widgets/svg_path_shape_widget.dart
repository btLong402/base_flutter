import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// Widget base để tạo các khối có viền gradient từ SVG Path.
///
/// **Hướng dẫn sử dụng:**
/// ```dart
/// SvgPathShapeWidget(
///   // Path SVG được trích xuất (ví dụ từ Figma)
///   svgPathString: 'M0 0 H 100 V 100 H 0 Z',
///   // Kích thước gốc của view/box chứa path này trong design (để tự scale)
///   originalDesignSize: const Size(100, 100),
///   // Tuỳ chỉnh màu viền (tùy chọn)
///   borderGradientColors: const [Colors.white54, Colors.white10],
///   // Tuỳ chọn điểm dừng màu viền
///   borderStops: const [0.0, 1.0],
///   // Nội dung nằm bên trong shape
///   child: Container(
///     width: 100,
///     height: 100,
///     color: Colors.blue,
///   ),
/// )
/// ```
class SvgPathShapeWidget extends StatelessWidget {
  const SvgPathShapeWidget({
    required this.child,
    required this.svgPathString,
    required this.originalDesignSize,
    super.key,
    this.borderGradientColors = const [
      Color(0x80FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x66FFFFFF),
    ],
    this.borderStops = const [0, 0.5, 1],
  });

  final Widget child;
  final String svgPathString;
  final Size originalDesignSize;
  final List<Color> borderGradientColors;
  final List<double> borderStops;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SvgPathBorderPainter(
        svgPathString: svgPathString,
        originalDesignSize: originalDesignSize,
        borderGradientColors: borderGradientColors,
        stops: borderStops,
      ),
      child: ClipPath(
        clipper: SvgPathClipper(
          svgPathString: svgPathString,
          originalDesignSize: originalDesignSize,
        ),
        child: child,
      ),
    );
  }
}

class SvgPathClipper extends CustomClipper<Path> {
  SvgPathClipper({
    required this.svgPathString,
    required this.originalDesignSize,
  });

  final String svgPathString;
  final Size originalDesignSize;

  @override
  Path getClip(Size size) {
    final path = parseSvgPathData(svgPathString);

    // Tự động scale vừa với màn hình
    final matrix = Matrix4.diagonal3Values(
      size.width / originalDesignSize.width,
      size.height / originalDesignSize.height,
      1,
    );

    return path.transform(matrix.storage);
  }

  @override
  bool shouldReclip(covariant SvgPathClipper oldClipper) {
    return oldClipper.svgPathString != svgPathString ||
        oldClipper.originalDesignSize != originalDesignSize;
  }
}

class SvgPathBorderPainter extends CustomPainter {
  SvgPathBorderPainter({
    required this.svgPathString,
    required this.originalDesignSize,
    this.borderGradientColors = const [
      Color(0x80FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x66FFFFFF),
    ],
    this.stops = const [0.0, 0.5, 1.0],
  });

  final String svgPathString;
  final Size originalDesignSize;
  final List<Color> borderGradientColors;
  final List<double> stops;

  @override
  void paint(Canvas canvas, Size size) {
    final path = parseSvgPathData(svgPathString);

    final matrix = Matrix4.diagonal3Values(
      size.width / originalDesignSize.width,
      size.height / originalDesignSize.height,
      1,
    );
    final scaledPath = path.transform(matrix.storage);

    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: borderGradientColors,
      stops: stops,
    ).createShader(rect);

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0.5);

    canvas.drawPath(scaledPath, paint);
  }

  @override
  bool shouldRepaint(covariant SvgPathBorderPainter oldDelegate) {
    return oldDelegate.svgPathString != svgPathString ||
        oldDelegate.originalDesignSize != originalDesignSize ||
        oldDelegate.borderGradientColors != borderGradientColors;
  }
}
