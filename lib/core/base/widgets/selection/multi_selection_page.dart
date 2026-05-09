import 'dart:async';

import 'package:base_flutter/core/base/widgets/app_bar/animated_search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/widgets/infinite_scroll/infinite_scroll.dart';
import 'package:base_flutter/core/base/widgets/input/app_search_bar.dart';
import 'package:base_flutter/core/base/widgets/selection/selection_page.dart';

/// Generic multi-selection page with search and infinite scroll.
///
/// Navigates back with list of selected items via [Navigator.pop].
class MultiSelectionPage<T> extends StatefulWidget {
  const MultiSelectionPage({
    required this.title,
    required this.fetchItems,
    required this.itemBuilder,
    required this.valueKey,
    super.key,
    this.selectedIds = const [],
    this.searchHint = 'Tìm kiếm...',
    this.emptyMessage = 'Không có dữ liệu',
    this.pageSize = 20,
    this.onAddNew,
    this.fabTooltip = 'Thêm mới',
    this.fabIcon = Icons.add,
    this.confirmLabel = 'Xác nhận',
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

  /// Currently selected item keys (for pre-selection).
  final List<String> selectedIds;

  /// Placeholder text for the search field.
  final String searchHint;

  /// Message shown when no items are found.
  final String emptyMessage;

  /// Number of items per page.
  final int pageSize;

  /// Called when the FAB is tapped.
  final Future<T?> Function()? onAddNew;

  /// Tooltip text for the FAB.
  final String fabTooltip;

  /// Icon for the FAB.
  final IconData fabIcon;

  /// Text for confirm button.
  final String confirmLabel;

  @override
  State<MultiSelectionPage<T>> createState() => _MultiSelectionPageState<T>();
}

class _MultiSelectionPageState<T> extends State<MultiSelectionPage<T>> {
  late final PaginationController<T> _controller;
  final _searchController = TextEditingController();

  /// Selected items tracked by key -> item
  final _selectedMap = <String, T>{};

  String _keyword = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
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
      onPageLoaded: (items) {
        // Pre-select items matching selectedIds when a new page is loaded
        for (final item in items) {
          final key = widget.valueKey(item);
          if (widget.selectedIds.contains(key)) {
            _selectedMap[key] = item;
          }
        }
        // Force rebuild of confirm bar / badge
        if (mounted) setState(() {});
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
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_keyword != value) {
        setState(() async {
          _keyword = value;
          await _controller.refresh();
        });
      }
    });
  }

  void _toggleItem(T item) {
    final key = widget.valueKey(item);
    setState(() {
      if (_selectedMap.containsKey(key)) {
        _selectedMap.remove(key);
      } else {
        _selectedMap[key] = item;
      }
    });
  }

  void _selectAll() {
    setState(() {
      for (final item in _controller.items) {
        _selectedMap[widget.valueKey(item)] = item;
      }
    });
  }

  void _deselectAll() {
    setState(_selectedMap.clear);
  }

  void _onConfirm() {
    Navigator.pop(context, _selectedMap.values.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get current items from controller for comparison
    final currentItems = _controller.items;
    final isAllSelected =
        currentItems.isNotEmpty &&
        currentItems.every(
          (item) => _selectedMap.containsKey(widget.valueKey(item)),
        );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AnimatedSearchAppBar(
        title: Text(widget.title),
        onSearchChanged: _onSearchChanged,
        actions: [
          if (currentItems.isNotEmpty)
            TextButton(
              onPressed: isAllSelected ? _deselectAll : _selectAll,
              child: Text(
                isAllSelected ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          if (_selectedMap.isNotEmpty) _buildSelectedBadge(theme),
          Expanded(child: _buildContent(theme)),
        ],
      ),
      bottomNavigationBar: _selectedMap.isNotEmpty
          ? _buildConfirmBar(theme)
          : null,
      floatingActionButton: widget.onAddNew != null && _selectedMap.isEmpty
          ? FloatingActionButton.small(
              onPressed: () async {
                final result = await widget.onAddNew!();
                if (result != null && mounted) {
                  await _controller.refresh();
                }
              },
              tooltip: widget.fabTooltip,
              child: Icon(widget.fabIcon),
            )
          : null,
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: AppColors.surfaceLight,
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

  Widget _buildSelectedBadge(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Đã chọn ${_selectedMap.length} mục',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return InfiniteScrollView<T>(
      controller: _controller,
      padding: const EdgeInsets.symmetric(vertical: 4),
      emptyBuilder: (context) => _buildEmptyState(theme),
      itemBuilder: (context, index, item) {
        final key = widget.valueKey(item);
        final isSelected = _selectedMap.containsKey(key);

        return InkWell(
          onTap: () => _toggleItem(item),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          key: ValueKey('checked'),
                          color: AppColors.primary,
                          size: 22,
                        )
                      : const Icon(
                          Icons.radio_button_unchecked,
                          key: ValueKey('unchecked'),
                          color: AppColors.textTertiaryLight,
                          size: 22,
                        ),
                ),
              ),
              Expanded(
                child: widget.itemBuilder(
                  context,
                  item,
                  isSelected: isSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textTertiaryLight),
          const SizedBox(height: 12),
          Text(
            widget.emptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: _onConfirm,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          '${widget.confirmLabel} (${_selectedMap.length})',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}
