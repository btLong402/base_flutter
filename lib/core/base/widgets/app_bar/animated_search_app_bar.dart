import 'package:flutter/material.dart';
import 'package:base_flutter/core/base/widgets/input/app_text_field.dart';
import 'package:base_flutter/core/base/theme/app_colors.dart';

/// An AppBar that supports an animated search field toggled by a search icon.
class AnimatedSearchAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  const AnimatedSearchAppBar({
    required this.onSearchChanged,
    required this.title,
    super.key,
    this.bottom,
    this.actions = const [],
    this.onSearchSubmitted,
    this.searchHint = 'Tìm kiếm...',
  });

  final Widget title;
  final PreferredSizeWidget? bottom;
  final List<Widget> actions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final String searchHint;

  @override
  State<AnimatedSearchAppBar> createState() => _AnimatedSearchAppBarState();

  @override
  Size get preferredSize {
    var height = kToolbarHeight;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}

class _AnimatedSearchAppBarState extends State<AnimatedSearchAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _searchBarAnimation = CurveTween(
      curve: Curves.easeInOut,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() async {
      _isSearching = !_isSearching;
      if (_isSearching) {
        await _animationController.forward();
        _searchFocusNode.requestFocus();
      } else {
        await _animationController.reverse();
        _searchFocusNode.unfocus();
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
          widget.onSearchChanged('');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Normal Title
          FadeTransition(
            opacity: Tween<double>(
              begin: 1,
              end: 0,
            ).animate(_searchBarAnimation),
            child: widget.title,
          ),
          // Search Bar
          SizeTransition(
            sizeFactor: _searchBarAnimation,
            axis: Axis.horizontal,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _searchBarAnimation,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  return AppTextField.compact(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: widget.searchHint,
                    prefixIcon: Icons.search,
                    fillColor: Colors.white,
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: AppColors.hint,
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                          )
                        : null,
                    onChanged: widget.onSearchChanged,
                    onSubmitted: widget.onSearchSubmitted,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: _toggleSearch,
        ),
        if (!_isSearching) ...widget.actions,
      ],
      bottom: widget.bottom,
    );
  }
}
