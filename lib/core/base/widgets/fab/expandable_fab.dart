import 'package:flutter/material.dart';

/// Expandable FAB widget that can be used with ShellFabController
///
/// Shows a main FAB that expands to show menu items when tapped.
/// Uses OverlayPortal for overlay management instead of Stack.
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    required this.mainColor,
    required this.menuItems,
    super.key,
    this.icon = Icons.add,
    this.closeIcon = Icons.close,
  });

  final Color mainColor;
  final IconData icon;
  final IconData closeIcon;
  final List<ExpandableFabItem> menuItems;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  final GlobalKey<State<StatefulWidget>> _fabKey = GlobalKey();
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() async {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _overlayController.show();
        await _animationController.forward();
      } else {
        await _animationController.reverse().then((_) {
          if (mounted && !_isExpanded) {
            _overlayController.hide();
          }
        });
      }
    });
  }

  Future<void> _close() async {
    if (_isExpanded) {
      setState(() => _isExpanded = false);
      await _animationController.reverse().then((_) {
        if (mounted) {
          _overlayController.hide();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _buildOverlay,
      child: FloatingActionButton(
        key: _fabKey,
        onPressed: _toggle,
        backgroundColor: widget.mainColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: _isExpanded ? 0.125 : 0,
          child: Icon(widget.icon),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    // Get the position of the FAB using the GlobalKey
    final renderBox = _fabKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final fabPosition = renderBox.localToGlobal(Offset.zero);
    final fabSize = renderBox.size;

    return Stack(
      children: [
        // Scrim/overlay background
        Positioned.fill(
          child: GestureDetector(
            onTap: _close,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        ),
        // Menu items
        Positioned(
          right:
              MediaQuery.of(context).size.width -
              fabPosition.dx -
              fabSize.width,
          bottom: MediaQuery.of(context).size.height - fabPosition.dy + 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.menuItems.length; i++) ...[
                SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.5, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _expandAnimation,
                          curve: Interval(
                            i * 0.1,
                            0.6 + i * 0.1,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: _buildMenuItem(widget.menuItems[i]),
                  ),
                ),
                if (i < widget.menuItems.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(ExpandableFabItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _close();
          item.onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item for ExpandableFab menu
class ExpandableFabItem {
  const ExpandableFabItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
