import 'dart:math';
import 'package:flutter/material.dart';

/// Các điểm ngắt (breakpoints) logic chuẩn cho chiều rộng màn hình hoặc kích thước khung chứa.
abstract class AppBreakpoints {
  /// Thiết bị siêu nhỏ (Smartwatch hoặc cửa sổ chia màn hình cực bé)
  static const double watch = 320;

  /// Thiết bị di động thông thường (Mobile)
  static const double mobile = 600;

  /// Máy tính bảng hoặc màn hình cỡ trung bình (Tablet / Phablet)
  static const double tablet = 1024;

  /// Màn hình máy tính lớn / 2K / 4K (Large Desktop / TV)
  static const double desktopXl = 1440;
}

/// Loại thiết bị được phân chia vật lý dựa trên cạnh ngắn nhất (shortest side) của màn hình.
enum DeviceCategory {
  /// Đồng hồ thông minh hoặc thiết bị cực nhỏ (< 320 dp)
  watch,

  /// Điện thoại thông minh (Phone)
  mobile,

  /// Máy tính bảng (Tablet)
  tablet,

  /// Máy tính để bàn / Laptop / Tivi (Desktop)
  desktop,
}

/// Widget xây dựng giao diện đáp ứng (Responsive) mạnh mẽ và linh hoạt.
/// Hỗ trợ cả hai chế độ:
/// 1. **Container-based Responsive**: Dựa trên kích thước vùng chứa của widget cha (`LayoutBuilder`).
/// 2. **Screen-based Responsive**: Dựa trên kích thước màn hình thiết bị thực tế (`MediaQuery`).
///
/// **Hướng dẫn sử dụng:**
/// ```dart
/// ResponsiveLayoutBuilder(
///   mobileBuilder: (context, constraints) => const MobileLayout(),
///   // Tablet và Desktop là tuỳ chọn. Nếu không truyền sẽ tự động fallback xuống thiết bị nhỏ hơn.
///   tabletBuilder: (context, constraints) => const TabletLayout(),
///   desktopBuilder: (context, constraints) => const DesktopLayout(),
/// )
/// ```
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    required this.mobileBuilder,
    super.key,
    this.watchBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
    this.desktopXlBuilder,
    this.portraitBuilder,
    this.landscapeBuilder,
  });

  /// Giao diện cho thiết bị di động (bắt buộc làm giao diện gốc/fallback)
  final Widget Function(BuildContext context, BoxConstraints constraints) mobileBuilder;

  /// Giao diện cho thiết bị cực nhỏ (như Smartwatch)
  final Widget Function(BuildContext context, BoxConstraints constraints)? watchBuilder;

  /// Giao diện cho máy tính bảng
  final Widget Function(BuildContext context, BoxConstraints constraints)? tabletBuilder;

  /// Giao diện cho màn hình máy tính bàn / Laptop
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktopBuilder;

  /// Giao diện cho màn hình siêu lớn (2K, 4K, Tivi)
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktopXlBuilder;

  /// Giao diện bổ trợ chỉ hiển thị khi thiết bị xoay dọc (Portrait)
  final Widget Function(BuildContext context, BoxConstraints constraints)? portraitBuilder;

  /// Giao diện bổ trợ chỉ hiển thị khi thiết bị xoay ngang (Landscape)
  final Widget Function(BuildContext context, BoxConstraints constraints)? landscapeBuilder;

  // ==========================================================================
  // BỘ UTILS TĨNH - ĐỊNH DANH THIẾT BỊ THEO TIÊU CHUẨN TRẢI NGHIỆM NGƯỜI DÙNG
  // ==========================================================================

  /// Lấy danh mục thiết bị thực tế (DeviceCategory) dựa trên cạnh ngắn nhất (shortest side).
  /// Đảm bảo tính chính xác ngay cả khi xoay màn hình (không nhận nhầm Phone xoay ngang thành Tablet).
  static DeviceCategory getDeviceCategory(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return DeviceCategory.mobile;
    }
    
    final size = mediaQuery.size;
    final shortestSide = min(size.width, size.height);

    if (shortestSide < AppBreakpoints.watch) {
      return DeviceCategory.watch;
    } else if (shortestSide < AppBreakpoints.mobile) {
      return DeviceCategory.mobile;
    } else if (shortestSide < 900) {
      // 600 dp -> 900 dp là khoảng kích thước của các dòng Tablet phổ thông (iPad, Galaxy Tab)
      return DeviceCategory.tablet;
    } else {
      return DeviceCategory.desktop;
    }
  }

  /// Kiểm tra xem thiết bị thực tế có phải là Điện thoại di động không (dựa trên shortest side)
  static bool isMobileDevice(BuildContext context) =>
      getDeviceCategory(context) == DeviceCategory.mobile;

  /// Kiểm tra xem thiết bị thực tế có phải là Máy tính bảng không (dựa trên shortest side)
  static bool isTabletDevice(BuildContext context) =>
      getDeviceCategory(context) == DeviceCategory.tablet;

  /// Kiểm tra xem thiết bị thực tế có phải là Máy tính bàn / Tivi không (dựa trên shortest side)
  static bool isDesktopDevice(BuildContext context) =>
      getDeviceCategory(context) == DeviceCategory.desktop;

  /// Kiểm tra hướng màn hình dọc (Portrait)
  static bool isPortrait(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.portrait;

  /// Kiểm tra hướng màn hình ngang (Landscape)
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  // ==========================================================================
  // BỘ UTILS TĨNH - KIỂM TRA ĐIỂM NGẮT (BREAKPOINTS) CỦA CỬA SỔ/MÀN HÌNH HIỆN TẠI
  // ==========================================================================

  /// Cửa sổ hiển thị hiện tại có độ rộng ở mức Mobile (< 600 dp)
  static bool isMobileScreen(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

  /// Cửa sổ hiển thị hiện tại có độ rộng ở mức Tablet (>= 600 dp && < 1024 dp)
  static bool isTabletScreen(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
  }

  /// Cửa sổ hiển thị hiện tại có độ rộng ở mức Desktop (>= 1024 dp)
  static bool isDesktopScreen(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        // 1. Kiểm tra hướng vùng chứa (nếu có yêu cầu render riêng theo hướng dọc/ngang của widget)
        if (landscapeBuilder != null && maxWidth > maxHeight) {
          return landscapeBuilder!(context, constraints);
        }
        if (portraitBuilder != null && maxHeight >= maxWidth) {
          return portraitBuilder!(context, constraints);
        }

        // 2. Chạy cơ chế tìm kiếm layout phù hợp theo chiều rộng vùng chứa (Container-based)
        if (maxWidth >= AppBreakpoints.desktopXl) {
          if (desktopXlBuilder != null) return desktopXlBuilder!(context, constraints);
          if (desktopBuilder != null) return desktopBuilder!(context, constraints);
          if (tabletBuilder != null) return tabletBuilder!(context, constraints);
        } else if (maxWidth >= AppBreakpoints.tablet) {
          if (desktopBuilder != null) return desktopBuilder!(context, constraints);
          if (tabletBuilder != null) return tabletBuilder!(context, constraints);
        } else if (maxWidth >= AppBreakpoints.mobile) {
          if (tabletBuilder != null) return tabletBuilder!(context, constraints);
        } else if (maxWidth < AppBreakpoints.watch) {
          if (watchBuilder != null) return watchBuilder!(context, constraints);
        }

        // 3. Fallback mặc định về mobile layout
        return mobileBuilder(context, constraints);
      },
    );
  }
}
