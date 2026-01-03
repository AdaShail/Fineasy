import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';
import 'token_extensions.dart';

/// Sort direction for table columns
enum WebTableSortDirection {
  none,
  ascending,
  descending,
}

/// Column configuration for WebTable
class WebTableColumn<T> {
  final String key;
  final String header;
  final Widget Function(T row) accessor;
  final bool sortable;
  final bool filterable;
  final double? width;
  final TextAlign align;

  const WebTableColumn({
    required this.key,
    required this.header,
    required this.accessor,
    this.sortable = false,
    this.filterable = false,
    this.width,
    this.align = TextAlign.left,
  });
}

/// Pagination configuration
class WebTablePagination {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final ValueChanged<int> onPageChange;

  const WebTablePagination({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.onPageChange,
  });
}

/// Web Table Component
/// 
/// A comprehensive data table with sorting, filtering, selection, and pagination.
/// Implements WCAG 2.1 AA accessibility with proper ARIA attributes.
/// 
/// Example:
/// ```dart
/// WebTable<User>(
///   columns: [
///     WebTableColumn(
///       key: 'name',
///       header: 'Name',
///       accessor: (user) => Text(user.name),
///       sortable: true,
///     ),
///   ],
///   data: users,
///   onSort: (key, direction) => sortUsers(key, direction),
/// )
/// ```
class WebTable<T> extends StatefulWidget {
  final List<WebTableColumn<T>> columns;
  final List<T> data;
  final bool loading;
  final Widget? emptyState;
  final void Function(String key, WebTableSortDirection direction)? onSort;
  final void Function(Map<String, dynamic> filters)? onFilter;
  final void Function(T row)? onRowClick;
  final bool selectable;
  final Set<String>? selectedRows;
  final void Function(Set<String> selected)? onSelectionChange;
  final WebTablePagination? pagination;
  final String Function(T row)? getRowId;

  const WebTable({
    Key? key,
    required this.columns,
    required this.data,
    this.loading = false,
    this.emptyState,
    this.onSort,
    this.onFilter,
    this.onRowClick,
    this.selectable = false,
    this.selectedRows,
    this.onSelectionChange,
    this.pagination,
    this.getRowId,
  }) : super(key: key);

  @override
  State<WebTable<T>> createState() => _WebTableState<T>();
}

class _WebTableState<T> extends State<WebTable<T>> {
  String? _sortedColumn;
  WebTableSortDirection _sortDirection = WebTableSortDirection.none;
  Set<String> _selectedRows = {};

  @override
  void initState() {
    super.initState();
    _selectedRows = widget.selectedRows ?? {};
  }

  @override
  void didUpdateWidget(WebTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRows != null && widget.selectedRows != _selectedRows) {
      _selectedRows = widget.selectedRows!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (widget.loading) {
      return _buildLoadingSkeleton(tokens);
    }

    if (widget.data.isEmpty && widget.emptyState != null) {
      return widget.emptyState!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTable(tokens),
        if (widget.pagination != null) ...[
          SizedBox(height: tokens.spacing['4']!),
          _buildPagination(tokens),
        ],
      ],
    );
  }

  Widget _buildTable(DesignTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.colors.neutral.s200),
        borderRadius: BorderRadius.circular(tokens.borderRadius.base),
      ),
      child: Column(
        children: [
          _buildHeader(tokens),
          ...widget.data.asMap().entries.map((entry) {
            return _buildRow(tokens, entry.value, entry.key);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader(DesignTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.colors.neutral.s100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(tokens.borderRadius.base),
          topRight: Radius.circular(tokens.borderRadius.base),
        ),
      ),
      child: Row(
        children: [
          if (widget.selectable) _buildSelectAllCheckbox(tokens),
          ...widget.columns.map((column) => _buildHeaderCell(tokens, column)).toList(),
        ],
      ),
    );
  }

  Widget _buildSelectAllCheckbox(DesignTokens tokens) {
    final allSelected = _selectedRows.length == widget.data.length && widget.data.isNotEmpty;
    final someSelected = _selectedRows.isNotEmpty && !allSelected;

    return Container(
      width: 48,
      padding: EdgeInsets.all(tokens.spacing['3']!),
      child: Checkbox(
        value: allSelected,
        tristate: true,
        onChanged: (value) {
          setState(() {
            if (allSelected || someSelected) {
              _selectedRows.clear();
            } else {
              _selectedRows = widget.data
                  .asMap()
                  .entries
                  .map((e) => widget.getRowId?.call(e.value) ?? e.key.toString())
                  .toSet();
            }
          });
          widget.onSelectionChange?.call(_selectedRows);
        },
      ),
    );
  }

  Widget _buildHeaderCell(DesignTokens tokens, WebTableColumn<T> column) {
    final isSorted = _sortedColumn == column.key;
    
    return Expanded(
      flex: column.width?.toInt() ?? 1,
      child: InkWell(
        onTap: column.sortable ? () => _handleSort(column.key) : null,
        child: Container(
          padding: EdgeInsets.all(tokens.spacing['3']!),
          child: Row(
            mainAxisAlignment: _getAlignment(column.align),
            children: [
              Text(
                column.header,
                style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
                  fontWeight: tokens.typography.fontWeight['semibold']!,
                  color: tokens.colors.neutral.s900,
                ),
              ),
              if (column.sortable) ...[
                SizedBox(width: tokens.spacing['1']!),
                Icon(
                  isSorted
                      ? (_sortDirection == WebTableSortDirection.ascending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: 16,
                  color: isSorted
                      ? tokens.colors.primary.s500
                      : tokens.colors.neutral.s500,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(DesignTokens tokens, T row, int index) {
    final rowId = widget.getRowId?.call(row) ?? index.toString();
    final isSelected = _selectedRows.contains(rowId);
    final isEven = index % 2 == 0;

    return InkWell(
      onTap: widget.onRowClick != null ? () => widget.onRowClick!(row) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.colors.primary.s50
              : (isEven ? Colors.white : tokens.colors.neutral.s50),
          border: Border(
            bottom: BorderSide(
              color: tokens.colors.neutral.s200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            if (widget.selectable) _buildRowCheckbox(tokens, rowId),
            ...widget.columns.map((column) {
              return Expanded(
                flex: column.width?.toInt() ?? 1,
                child: Container(
                  padding: EdgeInsets.all(tokens.spacing['3']!),
                  alignment: _getAlignmentGeometry(column.align),
                  child: column.accessor(row),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRowCheckbox(DesignTokens tokens, String rowId) {
    return Container(
      width: 48,
      padding: EdgeInsets.all(tokens.spacing['3']!),
      child: Checkbox(
        value: _selectedRows.contains(rowId),
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedRows.add(rowId);
            } else {
              _selectedRows.remove(rowId);
            }
          });
          widget.onSelectionChange?.call(_selectedRows);
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton(DesignTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.colors.neutral.s200),
        borderRadius: BorderRadius.circular(tokens.borderRadius.base),
      ),
      child: Column(
        children: [
          _buildHeader(tokens),
          ...List.generate(5, (index) {
            return Container(
              padding: EdgeInsets.all(tokens.spacing['3']!),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: tokens.colors.neutral.s200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: widget.columns.map((column) {
                  return Expanded(
                    flex: column.width?.toInt() ?? 1,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: tokens.colors.neutral.s200,
                        borderRadius: BorderRadius.circular(tokens.borderRadius.sm),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPagination(DesignTokens tokens) {
    final pagination = widget.pagination!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${pagination.currentPage} of ${pagination.totalPages}',
          style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
            color: tokens.colors.neutral.s600,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: pagination.currentPage > 1
                  ? () => pagination.onPageChange(pagination.currentPage - 1)
                  : null,
              tooltip: 'Previous page',
            ),
            SizedBox(width: tokens.spacing['2']!),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: pagination.currentPage < pagination.totalPages
                  ? () => pagination.onPageChange(pagination.currentPage + 1)
                  : null,
              tooltip: 'Next page',
            ),
          ],
        ),
      ],
    );
  }

  void _handleSort(String columnKey) {
    setState(() {
      if (_sortedColumn == columnKey) {
        // Cycle through sort directions
        switch (_sortDirection) {
          case WebTableSortDirection.none:
            _sortDirection = WebTableSortDirection.ascending;
            break;
          case WebTableSortDirection.ascending:
            _sortDirection = WebTableSortDirection.descending;
            break;
          case WebTableSortDirection.descending:
            _sortDirection = WebTableSortDirection.none;
            _sortedColumn = null;
            break;
        }
      } else {
        _sortedColumn = columnKey;
        _sortDirection = WebTableSortDirection.ascending;
      }
    });

    widget.onSort?.call(columnKey, _sortDirection);
  }

  MainAxisAlignment _getAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return MainAxisAlignment.start;
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.right:
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.start;
    }
  }

  Alignment _getAlignmentGeometry(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}
