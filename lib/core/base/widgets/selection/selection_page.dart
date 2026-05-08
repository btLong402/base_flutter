import 'dart:async';

import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/theme/app_text_styles.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll.dart';
import 'package:base_flutter/core/base/widgets/input/app_search_bar.dart';
import 'package:flutter/material.dart';

/// Result from a paginated fetch operation.
class SelectionResult<T> {
  const SelectionResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}

/// Callback type for fetching paginated items.
typedef SelectionFetcher<T> =
    Future<SelectionResult<T>> Function({
      required int page,
      required int pageSize,
      String? keyword,
    });

/// Generic selection page with search and infinite scroll.
///
/// Navigates back with the selected item via [Navigator.pop].
class SelectionPage<T> extends StatefulWidget {
  const SelectionPage({
    required this.title,
    required this.fetchItems,
    required this.itemBuilder,
    required this.valueKey,
    super.key,
    this.selectedId,
    this.isMultiSelection = false,
    this.initialSelectedItems = const [],
    this.searchHint = 'Tìm kiếm...',
    this.emptyMessage = 'Không có dữ liệu',
    this.pageSize = 20,
    this.showSearchBar = true,
    this.onAddNew,
    this.fabTooltip = 'Thêm mới',
    this.fabIcon = Icons.add,
  });

  /// Page title displayed in the AppBar.
  final String title;

  /// Fetches a page of items with optional keyword filter.
  final SelectionFetcher<T> fetchItems;

  /// Builds the widget for each item in the list.
  final Widget Function(
    BuildContext context,
    T item, {
    required bool isSelected,
  })
  itemBuilder;

  /// Extracts a unique key from an item for selection comparison.
  final String Function(T item) valueKey;

  /// The currently selected item's key (for highlighting).
  final String? selectedId;

  /// If true, multiple items can be selected.
  final bool isMultiSelection;

  /// Initially selected items (for multi selection).
  final List<T> initialSelectedItems;

  /// Placeholder text for the search field.
  final String searchHint;

  /// Message shown when no items are found.
  final String emptyMessage;

  /// Number of items per page.
  final int pageSize;

  /// Whether to show the search bar.
  final bool showSearchBar;

  /// Called when the FAB is tapped. If null, no FAB is shown.
  final Future<T?> Function()? onAddNew;

  /// Tooltip text for the FAB.
  final String fabTooltip;

  /// Icon for the FAB.
  final IconData fabIcon;

  @override
  State<SelectionPage<T>> createState() => _SelectionPageState<T>();
}

class _SelectionPageState<T> extends State<SelectionPage<T>> {
  late final PaginationController<T> _controller;
  final _searchController = TextEditingController();
  String _keyword = '';
  Timer? _debounce;
  late List<T> _currentSelectedItems;

  @override
  void initState() {
    super.initState();
    _currentSelectedItems = List<T>.from(widget.initialSelectedItems);
    _controller = PaginationController<T>(
      pageSize: widget.pageSize,
      loadPage: ({required page, required pageSize}) async {
        final result = await widget.fetchItems(
          page: page,
          pageSize: pageSize,
          keyword: _keyword.isEmpty ? null : _keyword,
        );
        return result.items;
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (_keyword != value) {
        _keyword = value;
        await _controller.refresh();
      }
    });
  }

  void _onItemTap(T item) {
    if (widget.isMultiSelection) {
      setState(() {
        final key = widget.valueKey(item);
        final index = _currentSelectedItems.indexWhere(
          (e) => widget.valueKey(e) == key,
        );
        if (index >= 0) {
          _currentSelectedItems.removeAt(index);
        } else {
          _currentSelectedItems.add(item);
        }
      });
    } else {
      Navigator.pop(context, item);
    }
  }

  Future<void> _onFabPressed() async {
    final result = await widget.onAddNew!();
    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context, result);
    } else {
      await _controller.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: widget.isMultiSelection
            ? [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, _currentSelectedItems);
                  },
                  child: Text(
                    'Xong',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      floatingActionButton: widget.onAddNew != null
          ? FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: _onFabPressed,
              tooltip: widget.fabTooltip,
              child: Icon(widget.fabIcon),
            )
          : null,
      body: Column(
        children: [
          if (widget.showSearchBar) _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: AppSearchBar(
        controller: _searchController,
        hintText: widget.searchHint,
        onChanged: _onSearchChanged,
        onClear: () {
          _searchController.clear();
          _onSearchChanged('');
        },
      ),
    );
  }

  Widget _buildBody() {
    return InfiniteScrollView<T>(
      controller: _controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (context, index) => const Divider(height: 1),
      emptyBuilder: (context) => _buildEmptyState(),
      loadingBuilder: (context) =>
          const ShimmerPlaceholder(itemCount: 10, itemHeight: 60),
      itemBuilder: (context, index, item) {
        final isSelected = widget.isMultiSelection
            ? _currentSelectedItems.any(
                (e) => widget.valueKey(e) == widget.valueKey(item),
              )
            : widget.selectedId != null &&
                  widget.valueKey(item) == widget.selectedId;

        return InkWell(
          onTap: () => _onItemTap(item),
          child: widget.itemBuilder(context, item, isSelected: isSelected),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.hint),
          const SizedBox(height: 12),
          Text(
            widget.emptyMessage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.hint),
          ),
        ],
      ),
    );
  }
}
