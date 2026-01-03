/// Virtual scrolling implementation for large lists
/// 
/// Optimizes rendering of large datasets by only rendering visible items
/// and a small buffer around them.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Virtual scroll list view for optimized rendering of large lists
class VirtualScrollListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double itemHeight;
  final int bufferSize;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final Widget? emptyWidget;

  const VirtualScrollListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.itemHeight,
    this.bufferSize = 5,
    this.controller,
    this.padding,
    this.emptyWidget,
  });

  @override
  State<VirtualScrollListView<T>> createState() =>
      _VirtualScrollListViewState<T>();
}

class _VirtualScrollListViewState<T> extends State<VirtualScrollListView<T>> {
  late ScrollController _scrollController;
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateVisibleRange();
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    _calculateVisibleRange();
  }

  void _calculateVisibleRange() {
    if (!mounted) return;

    final scrollOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;

    final firstVisible =
        (scrollOffset / widget.itemHeight).floor() - widget.bufferSize;
    final lastVisible = ((scrollOffset + viewportHeight) / widget.itemHeight)
            .ceil() +
        widget.bufferSize;

    final newFirst = firstVisible.clamp(0, widget.items.length - 1);
    final newLast = lastVisible.clamp(0, widget.items.length);

    if (newFirst != _firstVisibleIndex || newLast != _lastVisibleIndex) {
      setState(() {
        _firstVisibleIndex = newFirst;
        _lastVisibleIndex = newLast;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ??
          const Center(
            child: Text('No items to display'),
          );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.builder(
          controller: _scrollController,
          padding: widget.padding,
          itemCount: widget.items.length,
          itemExtent: widget.itemHeight,
          itemBuilder: (context, index) {
            // Only build items in visible range
            if (index < _firstVisibleIndex || index >= _lastVisibleIndex) {
              return SizedBox(height: widget.itemHeight);
            }

            return widget.itemBuilder(
              context,
              widget.items[index],
              index,
            );
          },
        );
      },
    );
  }
}

/// Virtual scroll grid view for optimized rendering of large grids
class VirtualScrollGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double itemHeight;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final int bufferRows;
  final ScrollController? controller;
  final EdgeInsets? padding;

  const VirtualScrollGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.itemHeight,
    required this.crossAxisCount,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.bufferRows = 2,
    this.controller,
    this.padding,
  });

  @override
  State<VirtualScrollGridView<T