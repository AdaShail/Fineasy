import 'package:flutter/material.dart';

/// Drag and drop data wrapper
class DragData<T> {
  final T data;
  final String type;
  final Map<String, dynamic>? metadata;

  const DragData({
    required this.data,
    required this.type,
    this.metadata,
  });
}

/// Draggable item widget
class DraggableItem<T> extends StatefulWidget {
  final T data;
  final Widget child;
  final Widget? feedback;
  final Widget? childWhenDragging;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;
  final VoidCallback? onDragCompleted;
  final VoidCallback? onDraggableCanceled;
  final String? dragType;
  final bool enabled;

  const DraggableItem({
    super.key,
    required this.data,
    required this.child,
    this.feedback,
    this.childWhenDragging,
    this.onDragStarted,
    this.onDragEnd,
    this.onDragCompleted,
    this.onDraggableCanceled,
    this.dragType,
    this.enabled = true,
  });

  @override
  State<DraggableItem<T>> createState() => _DraggableItemState<T>();
}

class _DraggableItemState<T> extends State<DraggableItem<T>> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Draggable<DragData<T>>(
      data: DragData(
        data: widget.data,
        type: widget.dragType ?? T.toString(),
      ),
      feedback: Material(
        elevation: 4,
        child: Opacity(
          opacity: 0.8,
          child: widget.feedback ?? widget.child,
        ),
      ),
      childWhenDragging: widget.childWhenDragging ??
          Opacity(
            opacity: 0.3,
            child: widget.child,
          ),
      onDragStarted: widget.onDragStarted,
      onDragEnd: (_) => widget.onDragEnd?.call(),
      onDragCompleted: widget.onDragCompleted,
      onDraggableCanceled: (_, __) => widget.onDraggableCanceled?.call(),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: widget.child,
      ),
    );
  }
}

/// Drop target widget
class DropTarget<T> extends StatefulWidget {
  final Widget child;
  final Function(DragData<T> data)? onAccept;
  final bool Function(DragData<T> data)? onWillAccept;
  final VoidCallback? onLeave;
  final Widget Function(BuildContext context, bool isHovering)? builder;
  final List<String>? acceptedTypes;

  const DropTarget({
    super.key,
    required this.child,
    this.onAccept,
    this.onWillAccept,
    this.onLeave,
    this.builder,
    this.acceptedTypes,
  });

  @override
  State<DropTarget<T>> createState() => _DropTargetState<T>();
}

class _DropTargetState<T> extends State<DropTarget<T>> {
  bool _isHovering = false;

  bool _willAccept(DragData<T>? data) {
    if (data == null) return false;

    // Check if type is accepted
    if (widget.acceptedTypes != null &&
        !widget.acceptedTypes!.contains(data.type)) {
      return false;
    }

    // Custom validation
    if (widget.onWillAccept != null) {
      return widget.onWillAccept!(data);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragData<T>>(
      onWillAccept: _willAccept,
      onAccept: (data) {
        setState(() => _isHovering = false);
        widget.onAccept?.call(data);
      },
      onMove: (details) {
        if (!_isHovering) {
          setState(() => _isHovering = true);
        }
      },
      onLeave: (_) {
        setState(() => _isHovering = false);
        widget.onLeave?.call();
      },
      builder: (context, candidateData, rejectedData) {
        if (widget.builder != null) {
          return widget.builder!(context, _isHovering);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: _isHovering
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
            color: _isHovering
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Reorderable list with drag and drop
class DragDropReorderableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Function(int oldIndex, int newIndex)? onReorder;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool shrinkWrap;

  const DragDropReorderableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onReorder,
    this.scrollController,
    this.padding,
    this.shrinkWrap = false,
  });

  @override
  State<DragDropReorderableList<T>> createState() =>
      _DragDropReorderableListState<T>();
}

class _DragDropReorderableListState<T> extends State<DragDropReorderableList<T>> {
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isDragging = _draggingIndex == index;

        return DropTarget<int>(
          onWillAccept: (data) => data.data != index,
          onAccept: (data) {
            if (widget.onReorder != null) {
              widget.onReorder!(data.data, index);
            }
            setState(() {
              _draggingIndex = null;
            });
          },
          builder: (context, hovering) {
            return DraggableItem<int>(
              data: index,
              onDragStarted: () {
                setState(() => _draggingIndex = index);
              },
              onDragEnd: () {
                setState(() => _draggingIndex = null);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  border: hovering
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Opacity(
                  opacity: isDragging ? 0.5 : 1.0,
                  child: widget.itemBuilder(context, item, index),
                ),
              ),
            );
          },
          child: const SizedBox.shrink(),
        );
      },
    );
  }
}

/// File drop zone for file uploads
class FileDropZone extends StatefulWidget {
  final Function(List<String> files)? onFilesDropped;
  final Widget? child;
  final String? hintText;
  final List<String>? allowedExtensions;

  const FileDropZone({
    super.key,
    this.onFilesDropped,
    this.child,
    this.hintText,
    this.allowedExtensions,
  });

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isHovering
                ? theme.colorScheme.primary
                : theme.dividerColor,
            width: _isHovering ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _isHovering
              ? theme.colorScheme.primaryContainer.withOpacity(0.1)
              : null,
        ),
        child: widget.child ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 64,
                    color: _isHovering
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.hintText ?? 'Drop files here',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _isHovering
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (widget.allowedExtensions != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Allowed: ${widget.allowedExtensions!.join(", ")}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      ),
    );
  }
}
