import 'package:flutter/material.dart';

/// Các điểm ngắt (breakpoints) cơ bản cho kích thước thiết bị
abstract class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

/// Widget base giúp dễ dàng chia layout theo từng loại thiết bị (Mobile, Tablet, Desktop)
/// Sử dụng `LayoutBuilder` theo chuẩn gợi ý để tối ưu hiệu năng và dễ maintain.
///
/// **Hướng dẫn sử dụng:**
/// ```dart
/// ResponsiveLayoutBuilder(
///   mobileBuilder: (context) => const MobileLayout(),
///   // Tablet và Desktop là tuỳ chọn. Nếu không truyền sẽ tự fallback xuống kích thước nhỏ hơn.
///   tabletBuilder: (context) => const TabletLayout(),
///   desktopBuilder: (context) => const DesktopLayout(),
/// )
/// ```
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    required this.mobileBuilder,
    super.key,
    this.tabletBuilder,
    this.desktopBuilder,
  });

  /// Giao diện mặc định cho thiết bị di động (bắt buộc)
  final WidgetBuilder mobileBuilder;

  /// Giao diện cho máy tính bảng.
  /// Nếu không truyền, sẽ fallback về mobileBuilder
  final WidgetBuilder? tabletBuilder;

  /// Giao diện cho màn hình lớn/desktop.
  /// Nếu không truyền, sẽ fallback về tabletBuilder hoặc mobileBuilder
  final WidgetBuilder? desktopBuilder;

  /// Kiểm tra xem hiện tại có phải thiết bị màn hình nhỏ (mobile) không
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

  /// Kiểm tra xem hiện tại có phải máy tính bảng (tablet) không
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
  }

  /// Kiểm tra xem hiện tại có phải màn hình lớn (desktop/web) không
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        if (maxWidth >= AppBreakpoints.tablet) {
          // Trả về desktop layout nếu có, nếu không thì rớt xuống tablet hoặc mobile
          if (desktopBuilder != null) {
            return desktopBuilder!(context);
          }
          if (tabletBuilder != null) {
            return tabletBuilder!(context);
          }
        } else if (maxWidth >= AppBreakpoints.mobile) {
          // Trả về tablet layout nếu có, nếu không rớt xuống mobile
          if (tabletBuilder != null) {
            return tabletBuilder!(context);
          }
        }

        // Mặc định trả về mobile
        return mobileBuilder(context);
      },
    );
  }
}
