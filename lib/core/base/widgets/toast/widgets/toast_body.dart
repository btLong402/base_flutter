import 'dart:async';

import 'package:base_flutter/core/base/widgets/toast/models/toast_config.dart';
import 'package:base_flutter/core/base/widgets/toast/models/toast_type.dart';
import 'package:flutter/material.dart';

/// Content of the toast (separated for performance)
class ToastBody extends StatelessWidget {
  const ToastBody({
    required this.config,
    super.key,
    this.onDismiss,
    this.onAction,
  });

  final ToastConfig config;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final type = config.type;
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          constraints: BoxConstraints(maxWidth: config.maxWidth, minHeight: 60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: type.color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: config.title != null
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: type.backgroundColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(type.icon, color: type.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (config.title != null) ...[
                              Text(
                                config.title!,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[900],
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              config.message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                                height: 1.3,
                              ),
                            ),
                            if (config.actionLabel != null &&
                                onAction != null) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  onAction?.call();
                                  onDismiss?.call();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: type.color,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  config.actionLabel!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (onDismiss != null)
                        Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: IconButton(
                              onPressed: onDismiss,
                              icon: const Icon(Icons.close, size: 18),
                              color: Colors.grey[500],
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Dismiss',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (config.showProgressBar && config.duration != Duration.zero)
                  ToastProgressBar(
                    duration: config.duration,
                    color: type.color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated progress bar for toast duration
class ToastProgressBar extends StatefulWidget {
  const ToastProgressBar({
    required this.duration,
    required this.color,
    super.key,
  });

  final Duration duration;
  final Color color;

  @override
  State<ToastProgressBar> createState() => _ToastProgressBarState();
}

class _ToastProgressBarState extends State<ToastProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: 1 - _controller.value,
            backgroundColor: widget.color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          );
        },
      ),
    );
  }
}
