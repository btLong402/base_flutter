import 'package:base_flutter/core/base/widgets/base_responsive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// A test page implementation with all overrides implemented
class FullTestResponsivePage extends BaseResponsivePage {
  const FullTestResponsivePage({
    required this.useDeviceTypeVal,
    super.key,
  });

  final bool useDeviceTypeVal;

  @override
  bool get useDeviceType => useDeviceTypeVal;

  @override
  Widget buildMobile(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Mobile Default/Portrait');
  }

  @override
  Widget? buildMobileLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Mobile Landscape');
  }

  @override
  Widget? buildTablet(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Tablet Default/Portrait');
  }

  @override
  Widget? buildTabletLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Tablet Landscape');
  }

  @override
  Widget? buildDesktop(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Desktop Default/Portrait');
  }

  @override
  Widget? buildDesktopLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Desktop Landscape');
  }

  @override
  Widget? buildDesktopXl(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('DesktopXl Default/Portrait');
  }

  @override
  Widget? buildDesktopXlLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('DesktopXl Landscape');
  }

  @override
  Widget? buildWatch(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Watch Default/Portrait');
  }

  @override
  Widget? buildWatchLandscape(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Watch Landscape');
  }
}

// A minimal test page implementation to verify fallback logic
class FallbackTestResponsivePage extends BaseResponsivePage {
  const FallbackTestResponsivePage({
    required this.useDeviceTypeVal,
    super.key,
    this.tabletWidget,
    this.desktopWidget,
  });

  final bool useDeviceTypeVal;
  final Widget? tabletWidget;
  final Widget? desktopWidget;

  @override
  bool get useDeviceType => useDeviceTypeVal;

  @override
  Widget buildMobile(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return const Text('Fallback Mobile General');
  }

  @override
  Widget? buildTablet(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return tabletWidget;
  }

  @override
  Widget? buildDesktop(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    return desktopWidget;
  }
}

void main() {
  setUp(() {
    // Reset standard screen sizes if modified
  });

  Future<void> setScreenSize(
    WidgetTester tester,
    double width,
    double height,
  ) async {
    final size = Size(width, height);
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
  }

  group('BaseResponsivePage - Device Type Mode (useDeviceType = true)', () {
    testWidgets('should render Watch layouts', (tester) async {
      await setScreenSize(tester, 300, 300);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FullTestResponsivePage(useDeviceTypeVal: true),
          ),
        ),
      );

      expect(find.text('Watch Default/Portrait'), findsOneWidget);
    });

    testWidgets('should render Watch Landscape layout when in landscape', (
      tester,
    ) async {
      await setScreenSize(tester, 310, 200); // shortestSide is 200 (<320 watch)

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FullTestResponsivePage(useDeviceTypeVal: true),
          ),
        ),
      );

      expect(find.text('Watch Landscape'), findsOneWidget);
    });

    testWidgets('should render Mobile Portrait layout', (tester) async {
      await setScreenSize(tester, 375, 667);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FullTestResponsivePage(useDeviceTypeVal: true),
          ),
        ),
      );

      expect(find.text('Mobile Default/Portrait'), findsOneWidget);
    });

    testWidgets('should render Mobile Landscape layout', (tester) async {
      await setScreenSize(
        tester,
        667,
        375,
      ); // shortestSide is 375 (<600 mobile)

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FullTestResponsivePage(useDeviceTypeVal: true),
          ),
        ),
      );

      expect(find.text('Mobile Landscape'), findsOneWidget);
    });

    testWidgets('should render Tablet Portrait layout', (tester) async {
      await setScreenSize(tester, 768, 1024);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FullTestResponsivePage(useDeviceTypeVal: true),
          ),
        ),
      );

      expect(find.text('Tablet Default/Portrait'), findsOneWidget);
    });

    testWidgets('should render Tablet Landscape layout', (tester) async {
      await setScreenSize(
        tester,
        1024,
        768,
      ); // shortestSide is 768 (<900 tablet)

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FullTestResponsivePage(useDeviceTypeVal: true),
          ),
        ),
      );

      expect(find.text('Tablet Landscape'), findsOneWidget);
    });

    testWidgets('should render Desktop Portrait layout', (tester) async {
      // In DeviceCategory logic, shortestSide >= 900 is desktop
      await setScreenSize(tester, 950, 1200);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FullTestResponsivePage(useDeviceTypeVal: true),
          ),
        ),
      );

      expect(find.text('Desktop Default/Portrait'), findsOneWidget);
    });

    testWidgets('should render Desktop Landscape layout', (tester) async {
      await setScreenSize(tester, 1200, 950);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FullTestResponsivePage(useDeviceTypeVal: true),
          ),
        ),
      );

      expect(find.text('Desktop Landscape'), findsOneWidget);
    });

    testWidgets(
      'should render DesktopXl Landscape layout when width is >= 1440',
      (tester) async {
        await setScreenSize(tester, 1440, 950);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: FullTestResponsivePage(useDeviceTypeVal: true),
            ),
          ),
        );

        expect(find.text('DesktopXl Landscape'), findsOneWidget);
      },
    );
  });

  group('BaseResponsivePage - Fallback Mechanism', () {
    testWidgets(
      'should fall back to general layout if orientation layout is missing',
      (tester) async {
        await setScreenSize(tester, 768, 1024);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: FallbackTestResponsivePage(
                useDeviceTypeVal: true,
                tabletWidget: Text('Fallback Tablet General'),
              ),
            ),
          ),
        );

        expect(find.text('Fallback Tablet General'), findsOneWidget);
      },
    );

    testWidgets('should fall back to mobile if tablet layout is missing', (
      tester,
    ) async {
      await setScreenSize(tester, 768, 1024);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FallbackTestResponsivePage(
              useDeviceTypeVal: true,
            ),
          ),
        ),
      );

      expect(find.text('Fallback Mobile General'), findsOneWidget);
    });

    testWidgets(
      'should fall back from desktop to tablet to mobile when missing intermediate layouts',
      (tester) async {
        await setScreenSize(tester, 1200, 950);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: FallbackTestResponsivePage(
                useDeviceTypeVal: true,
              ),
            ),
          ),
        );

        expect(find.text('Fallback Mobile General'), findsOneWidget);
      },
    );
  });

  group(
    'BaseResponsivePage - Container-based Mode (useDeviceType = false)',
    () {
      testWidgets('should render based on container size and orientation', (
        tester,
      ) async {
        // Container size: width 800, height 600 -> Tablet, Landscape
        await setScreenSize(tester, 800, 600);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: FullTestResponsivePage(useDeviceTypeVal: false),
            ),
          ),
        );

        expect(find.text('Tablet Landscape'), findsOneWidget);
      });

      testWidgets('should render Desktop when width is >= 1024 and landscape', (
        tester,
      ) async {
        await setScreenSize(tester, 1100, 700);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: FullTestResponsivePage(useDeviceTypeVal: false),
            ),
          ),
        );

        expect(find.text('Desktop Landscape'), findsOneWidget);
      });
    },
  );
}
