import 'dart:async';

import 'package:base_flutter/core/base/widgets/empty/app_empty_widget.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll_view.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/load_more_footer.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/pagination_controller.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/scroll_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('InfiniteScrollView - UI States Rendering', () {
    testWidgets('renders InfiniteScrollLoadingState when controller is loading',
        (tester) async {
      final completer = Completer<List<String>>();
      final controller = PaginationController<String>(
        pageSize: 10,
        loadPage: ({required page, required pageSize}) => completer.future,
      );

      await tester.pumpWidget(
        buildApp(
          InfiniteScrollView<String>(
            controller: controller,
            itemBuilder: (context, index, item) => Text(item),
          ),
        ),
      );

      // Microtask triggers refresh, pump to schedule frame
      await tester.pump();

      expect(find.byType(InfiniteScrollLoadingState), findsOneWidget);
      expect(find.text('Đang tải...'), findsOneWidget);

      completer.complete(['Hello', 'World']);
      await tester.pumpAndSettle();

      expect(find.byType(InfiniteScrollLoadingState), findsNothing);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('World'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders InfiniteScrollEmptyState when data is empty',
        (tester) async {
      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 10,
        loadPage: ({required page, required pageSize}) async => [],
      );

      await tester.pumpWidget(
        buildApp(
          InfiniteScrollView<String>(
            controller: controller,
            itemBuilder: (context, index, item) => Text(item),
          ),
        ),
      );

      await controller.refresh();
      await tester.pumpAndSettle();

      expect(find.byType(InfiniteScrollEmptyState), findsOneWidget);
      expect(find.byType(AppEmptyWidget), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders InfiniteScrollErrorState and triggers retry',
        (tester) async {
      var fail = true;
      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 10,
        loadPage: ({required page, required pageSize}) async {
          if (fail) throw Exception('Fetch failed');
          return ['Recovered Item'];
        },
      );

      await tester.pumpWidget(
        buildApp(
          InfiniteScrollView<String>(
            controller: controller,
            itemBuilder: (context, index, item) => Text(item),
          ),
        ),
      );

      await controller.refresh();
      await tester.pumpAndSettle();

      expect(find.byType(InfiniteScrollErrorState), findsOneWidget);
      expect(find.text('Lỗi kết nối'), findsOneWidget);

      fail = false;
      // Tap retry button
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();

      expect(find.byType(InfiniteScrollErrorState), findsNothing);
      expect(find.text('Recovered Item'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders LoadMoreFooter with endLabel when hasMore is false',
        (tester) async {
      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 5,
        loadPage: ({required page, required pageSize}) async =>
            ['A', 'B'], // Less than pageSize => hasMore = false
      );

      await tester.pumpWidget(
        buildApp(
          InfiniteScrollView<String>(
            controller: controller,
            itemBuilder: (context, index, item) => ListTile(title: Text(item)),
          ),
        ),
      );

      await controller.refresh();
      await tester.pumpAndSettle();

      expect(find.byType(LoadMoreFooter), findsOneWidget);
      expect(find.text('Hết dữ liệu'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders properly with useSlivers = true', (tester) async {
      final controller = PaginationController<String>(
        autoStart: false,
        pageSize: 5,
        loadPage: ({required page, required pageSize}) async =>
            ['Sliver 1', 'Sliver 2'],
      );

      await tester.pumpWidget(
        buildApp(
          InfiniteScrollView<String>(
            controller: controller,
            useSlivers: true,
            sliverAppBar: const SliverAppBar(
              title: Text('Sliver Header'),
            ),
            itemBuilder: (context, index, item) => ListTile(title: Text(item)),
          ),
        ),
      );

      await controller.refresh();
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.text('Sliver Header'), findsOneWidget);
      expect(find.text('Sliver 1'), findsOneWidget);
      expect(find.text('Sliver 2'), findsOneWidget);

      controller.dispose();
    });
  });
}
