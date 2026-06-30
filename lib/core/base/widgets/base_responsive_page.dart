import 'package:base_flutter/core/base/widgets/responsive_layout_builder.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Lớp cơ sở (Base Class) giúp xây dựng một Trang Responsive nhanh chóng và chuyên nghiệp.
///
/// Các trang kế thừa từ [BaseResponsivePage] chỉ cần override các phương thức dựng layout mong muốn.
/// Lớp này kế thừa trực tiếp từ [HookConsumerWidget] giúp trang của bạn được trang bị sẵn:
/// 1. Khả năng đọc/lắng nghe State của Riverpod (`WidgetRef ref`).
/// 2. Khả năng sử dụng Flutter Hooks (`usePageState`, `useAnimationController`,...).
///
/// **Cơ chế xử lý Lỗi Biên (Edge Cases):**
/// - **Hook-safe**: Tránh việc gọi trước các builder con với BoxConstraints giả lập (lỗi gọi trùng lặp Hook).
///   Các builder chỉ được gọi duy nhất một lần khi thiết bị đạt đúng điều kiện kích thước màn hình.
/// - **Fallback thông minh**: Tự động chuyển vùng giao diện từ lớn xuống nhỏ nếu các giao diện lớn hơn không được triển khai.
///
/// **Hướng dẫn sử dụng:**
/// ```dart
/// class MyPage extends BaseResponsivePage {
///   const MyPage({super.key});
///
///   @override
///   Widget buildMobile(BuildContext context, WidgetRef ref, BoxConstraints constraints) {
///     return const Center(child: Text('Giao diện Điện thoại'));
///   }
///
///   @override
///   Widget? buildTablet(BuildContext context, WidgetRef ref, BoxConstraints constraints) {
///     return const Center(child: Text('Giao diện Máy tính bảng'));
///   }
///
///   // Tùy chỉnh Scaffold nếu cần
///   @override
///   Widget buildScaffold(BuildContext context, WidgetRef ref, Widget body) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('My Page')),
///       body: body,
///     );
///   }
/// }
/// ```
abstract class BaseResponsivePage extends HookConsumerWidget {
  const BaseResponsivePage({super.key});

  /// Giao diện mặc định cho thiết bị di động (Bắt buộc).
  Widget buildMobile(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  );

  /// Giao diện cho di động xoay ngang (Không bắt buộc, fallback về buildMobile).
  Widget? buildMobileLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Giao diện cho máy tính bảng (Không bắt buộc, tự động fallback về mobile).
  Widget? buildTablet(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Giao diện cho máy tính bảng xoay ngang (Không bắt buộc, fallback về buildTablet).
  Widget? buildTabletLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Giao diện cho màn hình máy tính bàn (Không bắt buộc, tự động fallback về tablet hoặc mobile).
  Widget? buildDesktop(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Giao diện cho màn hình máy tính bàn xoay ngang (Không bắt buộc, fallback về buildDesktop).
  Widget? buildDesktopLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Giao diện cho màn hình siêu lớn (Không bắt buộc, tự động fallback về desktop).
  Widget? buildDesktopXl(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Giao diện cho màn hình siêu lớn xoay ngang (Không bắt buộc, fallback về buildDesktopXl).
  Widget? buildDesktopXlLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Giao diện cho đồng hồ hoặc thiết bị cực nhỏ (Không bắt buộc).
  Widget? buildWatch(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Giao diện cho đồng hồ xoay ngang (Không bắt buộc, fallback về buildWatch).
  Widget? buildWatchLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) => null;

  /// Quyết định xem có chuyển đổi bố cục dựa trên loại thiết bị thực tế hay không.
  /// Mặc định là `true` ở cấp trang (Page level) để đồng bộ hoàn toàn với hệ số scale của `AppScaleBuilder`.
  bool get useDeviceType => true;

  /// Hàm dựng khung trang (Scaffold) mặc định cho trang của bạn.
  /// Hãy override phương thức này nếu bạn cần tùy biến `AppBar`, `BackgroundColor`, `Drawer`, `FloatingActionButton`,...
  Widget buildScaffold(BuildContext context, WidgetRef ref, Widget body) {
    return Scaffold(
      body: body,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = ResponsiveLayoutBuilder(
      useDeviceType: useDeviceType,
      mobileBuilder: (context, constraints) {
        final isLandscape = useDeviceType
            ? MediaQuery.orientationOf(context) == Orientation.landscape
            : constraints.maxWidth > constraints.maxHeight;
        return _resolveMobile(context, ref, constraints, isLandscape);
      },
      watchBuilder: (context, constraints) {
        final isLandscape = useDeviceType
            ? MediaQuery.orientationOf(context) == Orientation.landscape
            : constraints.maxWidth > constraints.maxHeight;
        return _resolveWatch(context, ref, constraints, isLandscape);
      },
      tabletBuilder: (context, constraints) {
        final isLandscape = useDeviceType
            ? MediaQuery.orientationOf(context) == Orientation.landscape
            : constraints.maxWidth > constraints.maxHeight;
        return _resolveTablet(context, ref, constraints, isLandscape);
      },
      desktopBuilder: (context, constraints) {
        final isLandscape = useDeviceType
            ? MediaQuery.orientationOf(context) == Orientation.landscape
            : constraints.maxWidth > constraints.maxHeight;
        return _resolveDesktop(context, ref, constraints, isLandscape);
      },
      desktopXlBuilder: (context, constraints) {
        final isLandscape = useDeviceType
            ? MediaQuery.orientationOf(context) == Orientation.landscape
            : constraints.maxWidth > constraints.maxHeight;
        return _resolveDesktopXl(context, ref, constraints, isLandscape);
      },
    );

    return buildScaffold(context, ref, body);
  }

  Widget _resolveMobile(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
    bool isLandscape,
  ) {
    if (isLandscape) {
      final landscapeWidget = buildMobileLandscape(context, ref, constraints);
      if (landscapeWidget != null) return landscapeWidget;
    }
    return buildMobile(context, ref, constraints);
  }

  Widget _resolveWatch(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
    bool isLandscape,
  ) {
    if (isLandscape) {
      final landscapeWidget = buildWatchLandscape(context, ref, constraints);
      if (landscapeWidget != null) return landscapeWidget;
      final generalWidget = buildWatch(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    } else {
      final generalWidget = buildWatch(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    }
    return _resolveMobile(context, ref, constraints, isLandscape);
  }

  Widget _resolveTablet(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
    bool isLandscape,
  ) {
    if (isLandscape) {
      final landscapeWidget = buildTabletLandscape(context, ref, constraints);
      if (landscapeWidget != null) return landscapeWidget;
      final generalWidget = buildTablet(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    } else {
      final generalWidget = buildTablet(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    }
    return _resolveMobile(context, ref, constraints, isLandscape);
  }

  Widget _resolveDesktop(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
    bool isLandscape,
  ) {
    if (constraints.maxWidth >= AppBreakpoints.desktopXl) {
      return _resolveDesktopXl(context, ref, constraints, isLandscape);
    }
    if (isLandscape) {
      final landscapeWidget = buildDesktopLandscape(context, ref, constraints);
      if (landscapeWidget != null) return landscapeWidget;
      final generalWidget = buildDesktop(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    } else {
      final generalWidget = buildDesktop(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    }
    return _resolveTablet(context, ref, constraints, isLandscape);
  }

  Widget _resolveDesktopXl(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
    bool isLandscape,
  ) {
    if (isLandscape) {
      final landscapeWidget = buildDesktopXlLandscape(
        context,
        ref,
        constraints,
      );
      if (landscapeWidget != null) return landscapeWidget;
      final generalWidget = buildDesktopXl(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    } else {
      final generalWidget = buildDesktopXl(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    }
    return _resolveDesktopWithoutXlCheck(
      context,
      ref,
      constraints,
      isLandscape,
    );
  }

  Widget _resolveDesktopWithoutXlCheck(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
    bool isLandscape,
  ) {
    if (isLandscape) {
      final landscapeWidget = buildDesktopLandscape(context, ref, constraints);
      if (landscapeWidget != null) return landscapeWidget;
      final generalWidget = buildDesktop(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    } else {
      final generalWidget = buildDesktop(context, ref, constraints);
      if (generalWidget != null) return generalWidget;
    }
    return _resolveTablet(context, ref, constraints, isLandscape);
  }
}
