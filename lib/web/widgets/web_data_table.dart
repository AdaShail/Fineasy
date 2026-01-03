import 'package:flutter/material.dart';

/// Column configuration for WebDataTable
class WebDataColumn<T> {
  final String label;
  final String field;
  final double? width;
  final bool sortable;
  final bool visible;
  final Widget Function(T item)? cellBuilder;
  final String Function(T item)? valueGetter;

  const WebDataColumn({
    required this.label,
    required this.field,
    this.width,
    this.sortable = true,
    this.visible = true,
    this.cellBuilder,
    this.valueGetter,
  });
}

/// Enhanced data table with sorting, filtering, and pagination for web
class WebDataTable<T> extends StatefulWidget {
  final List<T> data;
  final List<WebDataColumn<T>> columns;
  final Function(T item)? onRowTap;
  final Function(List<T> selected)? onSelectionChanged;
  final bool selectable;
  final int rowsPerPage;
  final bool showPagination;
  final String? searchHint;
  final Function(String query)? onSearch;
  final List<Widget>? actions;
  final bool dense;

  const WebDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.onRowTap,
    this.onSelectionChanged,
    this.selectable = false,
    this.rowsPerPage = 10,
    this.showPagination = true,
    this.searchHint,
    this.onSearch,
    this.actions,
    this.dense = false,
  });

  @override
  State<WebDataTable<T>> createState() => _WebDataTableState<T>();
}

class _WebDataTableState<T> extends State<WebDataTable<T>> {
  int _currentPage = 0;
  String? _sortColumn;
  bool _sortAscending = true;
  final Set<T> _selectedItems = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredData {
    if (_searchQuery.isEmpty) return widget.data;
    
    return widget.data.where((item) {
      for (var column in widget.columns) {
        if (column.valueGetter != null) {
          final value = column.valueGetter!(item).toLowerCase();
          if (value.contains(_searchQuery.toLowerCase())) {
            return true;
          }
        }
      }
      return false;
    }).toList();
  }

  List<T> get _sortedData {
    final data = List<T>.from(_filteredData);
    
    if (_sortColumn != null) {
      final column = widget.columns.firstWhere((col) => col.field == _sortColumn);
      if (column.valueGetter != null) {
        data.sort((a, b) {
          final aValue = column.valueGetter!(a);
          final bValue = column.valueGetter!(b);
          final comparison = aValue.compareTo(bValue);
          return _sortAscending ? comparison : -comparison;
        });
      }
    }
    
    return data;
  }

  List<T> get _paginatedData {
    if (!widget.showPagination) return _sortedData;
    
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, _sortedData.length);
    return _sortedData.sublist(start, end);
  }

  int get _totalPages => (_sortedData.length / widget.rowsPerPage).ceil();

  void _handleSort(String field) {
    setState(() {
      if (_sortColumn == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = field;
        _sortAscending = true;
      }
    });
  }

  void _handleSelectAll(bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedItems.addAll(_paginatedData);
      } else {
        _selectedItems.clear();
      }
      widget.onSelectionChanged?.call(_selectedItems.toList());
    });
  }

  void _handleSelectItem(T item, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
      widget.onSelectionChanged?.call(_selectedItems.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleColumns = widget.columns.where((col) => col.visible).toList();

    return Semantics(
      label: 'Data table with ${_sortedData.length} rows',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          if (widget.searchHint != null || widget.actions != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (widget.searchHint != null)
                    Expanded(
                      child: Semantics(
                        label: 'Search table',
                        textField: true,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: widget.searchHint,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? Semantics(
                                    label: 'Clear search',
                                    button: true,
                                    child: IconButton(
                                      icon: const Icon(Icons.clear),
                                      tooltip: 'Clear search',
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                        widget.onSearch?.call('');
                                      },
                                    ),
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                            widget.onSearch?.call(value);
                          },
                        ),
                      ),
                    ),
                  if (widget.searchHint != null && widget.actions != null)
                    const SizedBox(width: 16),
                  if (widget.actions != null) ...widget.actions!,
                ],
              ),
            ),

          // Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: DataTable(
                  sortColumnIndex: _sortColumn != null
                      ? visibleColumns.indexWhere((col) => col.field == _sortColumn)
                      : null,
                  sortAscending: _sortAscending,
                  showCheckboxColumn: widget.selectable,
                  dataRowMinHeight: widget.dense ? 48 : 56,
                  dataRowMaxHeight: widget.dense ? 48 : 56,
                  headingRowHeight: widget.dense ? 48 : 56,
                  onSelectAll: widget.selectable ? _handleSelectAll : null,
                  columns: visibleColumns.map((column) {
                    return DataColumn(
                      label: Semantics(
                        label: '${column.label} column header',
                        child: Text(
                          column.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onSort: column.sortable
                          ? (columnIndex, ascending) => _handleSort(column.field)
                          : null,
                      tooltip: column.sortable ? 'Sort by ${column.label}' : null,
                    );
                  }).toList(),
                  rows: _paginatedData.map((item) {
                    final isSelected = _selectedItems.contains(item);
                    
                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: widget.selectable
                          ? (selected) => _handleSelectItem(item, selected)
                          : null,
                      cells: visibleColumns.map((column) {
                        return DataCell(
                          column.cellBuilder != null
                              ? column.cellBuilder!(item)
                              : Text(
                                  column.valueGetter?.call(item) ?? '',
                                  style: theme.textTheme.bodyMedium,
                                ),
                          onTap: () => widget.onRowTap?.call(item),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
            ),
          ),
        ),

          // Pagination
          if (widget.showPagination && _totalPages > 1)
            Semantics(
              label: 'Table pagination controls',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        'Showing ${_currentPage * widget.rowsPerPage + 1}-'
                        '${((_currentPage + 1) * widget.rowsPerPage).clamp(0, _sortedData.length)} '
                        'of ${_sortedData.length}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Row(
                      children: [
                        Semantics(
                          label: 'Previous page',
                          button: true,
                          enabled: _currentPage > 0,
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Previous page',
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                        ),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            'Page ${_currentPage + 1} of $_totalPages',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Semantics(
                          label: 'Next page',
                          button: true,
                          enabled: _currentPage < _totalPages - 1,
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Next page',
                            onPressed: _currentPage < _totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
