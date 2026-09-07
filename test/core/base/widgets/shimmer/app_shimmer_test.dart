import 'package:base_flutter/core/base/widgets/shimmer/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(Widget child, {Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('AppShimmer - UI/UX Animation & Functionality', () {
    testWidgets('renders child inside ShaderMask and RepaintBoundary when enabled',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          const AppShimmer(
            child: SizedBox(width: 100, height: 20),
          ),
        ),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('animates smoothly through duration and loops continuously',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          const AppShimmer(
            duration: Duration(milliseconds: 1000),
            child: SizedBox(width: 120, height: 40),
          ),
        ),
      );

      // Frame 0ms
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);

      // Frame 500ms (50% progress)
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShaderMask), findsOneWidget);

      // Frame 1000ms (completes first loop, starts second loop)
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isTrue);

      // Frame 1500ms
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('does not run animation or build ShaderMask when enabled is false',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          const AppShimmer(
            enabled: false,
            child: Text('Static Child'),
          ),
        ),
      );

      await tester.pump();

      // Should return child directly without ShaderMask overhead
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('Static Child'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('dynamically toggles animation when enabled property changes',
        (tester) async {
      var isEnabled = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildApp(
              Column(
                children: [
                  AppShimmer(
                    enabled: isEnabled,
                    child: const Text('Dynamic Child'),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isEnabled = !isEnabled),
                    child: const Text('Toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await tester.pump();
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);

      // Disable
      await tester.tap(find.text('Toggle'));
      await tester.pump();

      expect(find.byType(ShaderMask), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);

      // Re-enable
      await tester.tap(find.text('Toggle'));
      await tester.pump();

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('renders cleanly in both Light and Dark themes',
        (tester) async {
      // Light Mode
      await tester.pumpWidget(
        buildApp(
          const AppShimmer(
            child: SizedBox(width: 80, height: 16),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ShaderMask), findsOneWidget);

      // Dark Mode
      await tester.pumpWidget(
        buildApp(
          const AppShimmer(
            child: SizedBox(width: 80, height: 16),
          ),
          brightness: Brightness.dark,
        ),
      );
      await tester.pump();
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('AppShimmer.fromColors works as a drop-in replacement',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          const AppShimmer.fromColors(
            baseColor: Colors.red,
            highlightColor: Colors.yellow,
            child: SizedBox(width: 60, height: 60),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ShaderMask), findsOneWidget);

      // Advance frames to verify shader execution with custom colors
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('disposes controller cleanly without memory leaks',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          const AppShimmer(
            child: Text('Disposable Child'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Replace tree to trigger dispose
      await tester.pumpWidget(buildApp(const SizedBox()));
      await tester.pumpAndSettle();

      expect(find.byType(AppShimmer), findsNothing);
    });
  });
}
