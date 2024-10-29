import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Press and hold an item for 2 seconds to drag it to another position.',
              ),
              const SizedBox(height: 16),
              Dock(
                items: const [
                  Icons.person,
                  Icons.message,
                  Icons.call,
                  Icons.camera,
                  Icons.photo,
                ],
                builder: (icon) {
                  return Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    height: 48,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors
                          .primaries[icon.hashCode % Colors.primaries.length],
                    ),
                    child: Center(child: Icon(icon, color: Colors.white)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that displays a customizable dock with draggable icons.
class Dock<T> extends StatefulWidget {
  /// Creates a dock widget with a list of items and a builder for each item.
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  /// List of items to display in the dock.
  final List<T> items;

  /// Builder function to customize the appearance of each item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  /// Local copy of the dock items to modify during drag and drop.
  late final List<T> _items = widget.items.toList();

  /// Index of the item currently being dragged, if any.
  int? _draggedIndex;

  /// Index of the position where the dragged item is currently hovering.
  int _hoverIndex = -1;

  /// Whether the dragged item is outside the dock area.
  bool _isDraggedOutside = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 5), // Adjusted for smooth animation
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black12,
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:
              List.generate(_items.length + (_hoverIndex != -1 ? 1 : 0), (i) {
            // Display a space when an item is hovering over a position.
            if (_hoverIndex == i && !_isDraggedOutside) {
              return const SizedBox(width: 60, height: 48);
            }

            // Adjust index for hover state to insert gap appropriately.
            final adjustedIndex =
                i > _hoverIndex && _hoverIndex != -1 ? i - 1 : i;
            if (adjustedIndex >= _items.length) return const SizedBox.shrink();

            return _buildDockItem(adjustedIndex);
          }),
        ),
      ),
    );
  }

  /// Builds a draggable and droppable dock item at the specified index.
  Widget _buildDockItem(int i) {
    return DragTarget<int>(
      onAccept: (int fromIndex) {
        setState(() {
          _isDraggedOutside = false;
          final item = _items.removeAt(fromIndex);
          _items.insert(i, item);
          _draggedIndex = null;
          _hoverIndex = -1;
        });
      },
      onWillAccept: (fromIndex) {
        setState(() {
          if (fromIndex != i) _hoverIndex = i;
          _isDraggedOutside = false;
        });
        return true;
      },
      onLeave: (fromIndex) {
        setState(() {
          if (fromIndex != null) {
            _hoverIndex = -1;
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable(
          key: ValueKey(_items[i]),
          data: i,
          feedback: Material(
            child: widget.builder(_items[i]),
            color: Colors.transparent,
          ),
          childWhenDragging: const SizedBox.shrink(),
          onDragStarted: () {
            setState(() {
              _draggedIndex = i;
            });
          },
          onDraggableCanceled: (_, __) {
            setState(() {
              _draggedIndex = null;
              _hoverIndex = -1;
              _isDraggedOutside = false;
            });
          },
          onDragCompleted: () {
            setState(() {
              _draggedIndex = null;
              _hoverIndex = -1;
              _isDraggedOutside = false;
            });
          },
          child: widget.builder(_items[i]),
        );
      },
    );
  }
}
