import 'package:base_flutter/core/base/widgets/infinite_scroll/pagination_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the Home page pagination controller.
///
/// Uses autoDispose to ensure the controller and its timers are cleaned up
/// when the user navigates away from the Home feature for an extended period.
final Provider<PaginationController<String>> homePaginationControllerProvider =
    Provider.autoDispose<PaginationController<String>>((ref) {
      final controller = PaginationController<String>(
        pageSize: 15,
        loadPage: ({required page, required pageSize}) async {
          // Simulate network latency for a realistic infinite scroll feel
          await Future<void>.delayed(const Duration(milliseconds: 1200));

          // Mock data generation
          // In a real app, this would call a Repository/Use Case
          return List.generate(
            pageSize,
            (index) => 'Item ${(page * pageSize) + index + 1}',
          );
        },
      );

      // Link controller disposal to provider disposal
      ref.onDispose(controller.dispose);

      return controller;
    });
