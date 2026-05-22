import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget base giúp tự động khởi tạo môi trường tính toán scale (kích thước) cho toàn bộ ứng dụng.
/// Sử dụng package `flutter_screenutil` để tự động scale width, height, font size...
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
///       // designSize mặc định là 375x812 (chuẩn Figma Mobile), bạn có thể đổi nếu cần
///       designSize: const Size(375, 812),
///       builder: (context, child) {
///         return MaterialApp(
///           home: child, // Hoặc dùng route của bạn
///         );
///       },
///       child: const HomeScreen(), // Khởi tạo trang chủ (tuỳ chọn)
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
    this.designSize = const Size(375, 812),
    this.child,
  });

  /// Builder chứa `MaterialApp` hoặc router config của bạn
  final Widget Function(BuildContext context, Widget? child) builder;

  /// Kích thước bản thiết kế gốc (từ Figma/Sketch). Mặc định là 375 x 812.
  final Size designSize;

  /// Widget con tuỳ chọn (thường là màn hình trang chủ)
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: builder,
      child: child,
    );
  }
}
