import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Custom overlay for the barcode scanner viewport.
///
/// Draws a semi-transparent dark background with a clear scanning window
/// in the center, along with animated corner borders for a premium feel.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    super.key,
    this.scanWindowSize = 280,
    this.borderColor,
    this.hintText = 'Đưa mã vạch vào khung để quét',
  });

  /// Size of the square scanning window.
  final double scanWindowSize;

  /// Color for the corner borders. Defaults to [AppColors.primary].
  final Color? borderColor;

  /// Instruction text below the scanning window.
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppColors.primary;

    return Stack(
      children: [
        // Dark overlay with cutout
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: scanWindowSize,
                  height: scanWindowSize,
                  decoration: BoxDecoration(
                    color: Colors.red, // Any opaque color works for srcOut
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner borders
        Center(
          child: SizedBox(
            width: scanWindowSize,
            height: scanWindowSize,
            child: CustomPaint(
              painter: _CornerBorderPainter(
                color: color,
                cornerLength: 32,
                strokeWidth: 4,
                borderRadius: 16,
              ),
            ),
          ),
        ),

        // Hint text
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).size.height * 0.2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  hintText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Paints four rounded corner borders for the scan window.
class _CornerBorderPainter extends CustomPainter {
  _CornerBorderPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
    required this.borderRadius,
  });

  final Color color;
  final double cornerLength;
  final double strokeWidth;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final r = borderRadius;
    final cl = cornerLength;

    // Top-left corner
    canvas
      ..drawPath(
        Path()
          ..moveTo(0, cl)
          ..lineTo(0, r)
          ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
          ..lineTo(cl, 0),
        paint,
      )
      // Top-right corner
      ..drawPath(
        Path()
          ..moveTo(w - cl, 0)
          ..lineTo(w - r, 0)
          ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
          ..lineTo(w, cl),
        paint,
      )
      // Bottom-left corner
      ..drawPath(
        Path()
          ..moveTo(0, h - cl)
          ..lineTo(0, h - r)
          ..arcToPoint(Offset(r, h), radius: Radius.circular(r))
          ..lineTo(cl, h),
        paint,
      )
      // Bottom-right corner
      ..drawPath(
        Path()
          ..moveTo(w - cl, h)
          ..lineTo(w - r, h)
          ..arcToPoint(Offset(w, h - r), radius: Radius.circular(r))
          ..lineTo(w, h - cl),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _CornerBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
