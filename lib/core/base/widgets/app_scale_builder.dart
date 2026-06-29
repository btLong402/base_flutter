import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget base giúp tự động khởi tạo môi trường tính toán scale (kích thước) cho toàn bộ ứng dụng.
/// Tự động phát hiện và chuyển đổi thông minh giữa các bản thiết kế Phone & Tablet,
/// hỗ trợ tự động đảo chiều kích thước khi xoay màn hình (orientation) và tránh nhận diện nhầm Phone xoay ngang thành Tablet.
///
/// **Hướng dẫn sử dụng:**
/// Bọc widget này ngay bên ngoài `MaterialApp` (hoặc `CupertinoApp`) của bạn:
/// ```dart
/// void main() => runApp(const MyApp());
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return AppScaleBuilder(
///       phoneDesignSize: const Size(375, 812), // Chuẩn Figma Phone
///       tabletDesignSize: const Size(768, 1024), // Chuẩn Figma Tablet
///       builder: (context, child) {
///         return MaterialApp(
///           home: child,
///         );
///       },
///       child: const HomeScreen(),
///     );
///   }
/// }
/// ```
///
/// Sau khi khởi tạo, bạn có thể gọi:
/// - `50.w` (scale chiều rộng)
/// - `50.h` (scale chiều cao)
/// - `14.sp` (scale font size)
/// - `10.r` (scale radius)
class AppScaleBuilder extends StatelessWidget {
  const AppScaleBuilder({
    required this.builder,
    super.key,
    this.phoneDesignSize = const Size(375, 812),
    this.tabletDesignSize = const Size(768, 1024),
    this.tabletBreakpoint = 600.0,
    this.adaptOrientation = true,
    this.child,
  });

  /// Builder chứa `MaterialApp` hoặc router config của bạn
  final Widget Function(BuildContext context, Widget? child) builder;

  /// Kích thước bản thiết kế gốc cho điện thoại (Figma Mobile)
  final Size phoneDesignSize;

  /// Kích thước bản thiết kế gốc cho máy tính bảng (Figma Tablet)
  final Size tabletDesignSize;

  /// Điểm breakpoint để phân biệt thiết bị dựa trên cạnh ngắn nhất (shortest side).
  /// Tiêu chuẩn công nghiệp thường là 600 dp.
  final double tabletBreakpoint;

  /// Tự động hoán đổi chiều rộng và chiều cao của designSize khi thiết bị xoay ngang (Landscape).
  final bool adaptOrientation;

  /// Widget con tuỳ chọn (thường là màn hình trang chủ)
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // 1. Fallback an toàn cho môi trường Testing hoặc khi view chưa gắn kết hoàn toàn
    final view = View.maybeOf(context) ?? WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) {
      return _buildScreenUtil(phoneDesignSize);
    }

    // 2. Tính toán kích thước logic (dp) từ kích thước vật lý của View
    final physicalWidth = view.physicalSize.width;
    final physicalHeight = view.physicalSize.height;
    final devicePixelRatio = view.devicePixelRatio;

    final width = physicalWidth / (devicePixelRatio > 0 ? devicePixelRatio : 1.0);
    final height = physicalHeight / (devicePixelRatio > 0 ? devicePixelRatio : 1.0);

    // 3. Tiêu chuẩn vàng: Sử dụng shortest side để phân biệt Phone & Tablet (sw600dp),
    // giúp Phone xoay ngang (ví dụ 812x375) vẫn được nhận diện chính xác là Phone.
    final shortestSide = min(width, height);
    final isTablet = shortestSide >= tabletBreakpoint;

    // Chọn base size tương ứng với thiết bị
    final baseSize = isTablet ? tabletDesignSize : phoneDesignSize;

    // 4. Xử lý Orientation thích ứng
    final Size resolvedDesignSize;
    if (adaptOrientation && width > height) {
      // Thiết bị đang ở chế độ xoay ngang (Landscape)
      // Cấu hình designSize ngang: [Cạnh dài nhất, Cạnh ngắn nhất]
      final baseShortest = min(baseSize.width, baseSize.height);
      final baseLongest = max(baseSize.width, baseSize.height);
      resolvedDesignSize = Size(baseLongest, baseShortest);
    } else {
      // Thiết bị đang ở chế độ xoay dọc (Portrait) hoặc vuông
      // Cấu hình designSize dọc: [Cạnh ngắn nhất, Cạnh dài nhất]
      final baseShortest = min(baseSize.width, baseSize.height);
      final baseLongest = max(baseSize.width, baseSize.height);
      resolvedDesignSize = Size(baseShortest, baseLongest);
    }

    return _buildScreenUtil(resolvedDesignSize);
  }

  Widget _buildScreenUtil(Size designSize) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: builder,
      child: child,
    );
  }
}
