import 'package:flutter/material.dart';

/// Widget giúp chia nhỏ giao diện dựa theo hướng (dọc hoặc ngang) của vùng chứa (container).
/// Khác với `OrientationBuilder` của hệ thống (chỉ lắng nghe xoay thiết bị), widget này dựa trên
/// kích thước của vùng chứa thực tế (`BoxConstraints`), giúp hoạt động hoàn hảo trong các chế độ
/// chia đôi màn hình (Split View), cửa sổ ứng dụng (Web/Desktop) hoặc các Widget con tự co giãn.
///
/// **Cơ chế xử lý Lỗi Biên (Edge Cases):**
/// - **Unbounded Constraints (Vô cực)**: Nếu đặt widget này bên trong danh sách cuộn vô hạn
///   (ví dụ: `ListView` hoặc `SingleChildScrollView` chiều cao/rộng vô cực), so sánh kích thước
///   sẽ không còn chính xác. Hệ thống sẽ tự động fallback về hướng hiển thị vật lý của thiết bị (`MediaQuery`).
///
/// **Hướng dẫn sử dụng:**
/// ```dart
/// OrientationLayoutBuilder(
///   portraitBuilder: (context, constraints) => const PortraitView(),
///   landscapeBuilder: (context, constraints) => const LandscapeView(),
/// )
/// ```
class OrientationLayoutBuilder extends StatelessWidget {
  const OrientationLayoutBuilder({
    required this.portraitBuilder,
    required this.landscapeBuilder,
    super.key,
  });

  /// Giao diện khi vùng chứa có chiều dọc lớn hơn hoặc bằng chiều ngang (Portrait).
  final Widget Function(BuildContext context, BoxConstraints constraints) portraitBuilder;

  /// Giao diện khi vùng chứa có chiều ngang lớn hơn chiều dọc (Landscape).
  final Widget Function(BuildContext context, BoxConstraints constraints) landscapeBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        // 1. Nếu cả hai chiều đều có giới hạn rõ ràng, ta so sánh kích thước vùng chứa trực tiếp
        if (hasBoundedWidth && hasBoundedHeight) {
          if (constraints.maxWidth > constraints.maxHeight) {
            return landscapeBuilder(context, constraints);
          }
          return portraitBuilder(context, constraints);
        }

        // 2. Edge Case: Nếu có chiều bị vô hạn (ví dụ nằm trong ListView dọc/ngang không giới hạn)
        // Ta tự động fallback sử dụng hướng xoay thực tế của thiết bị thông qua MediaQuery
        final deviceOrientation = MediaQuery.maybeOrientationOf(context) ?? Orientation.portrait;
        if (deviceOrientation == Orientation.landscape) {
          return landscapeBuilder(context, constraints);
        }
        return portraitBuilder(context, constraints);
      },
    );
  }
}
