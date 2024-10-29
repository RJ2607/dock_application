import 'dart:developer';

import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
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
              Text(
                'Press and hold an item for 2 seconds to drag it to another position.',
              ),
              SizedBox(height: 16),
              Dock<Widget>(
                items: const [
                  Center(child: Icon(Icons.person, color: Colors.white)),
                  Center(child: Icon(Icons.message, color: Colors.white)),
                  Center(child: Icon(Icons.call, color: Colors.white)),
                  Center(child: Icon(Icons.camera, color: Colors.white)),
                  Center(child: Icon(Icons.photo, color: Colors.white)),
                ],
                builder: (e) {
                  return Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    height: 48,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors
                          .primaries[e.hashCode % Colors.primaries.length],
                    ),
                    child: e,
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

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  int? _draggedIndex;
  int? _hoveredIndex;
  final key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (i) {
            return LongPressDraggable(
              child: _buildDockItem(i),
              feedback: Material(
                child: widget.builder(_items[i]),
                color: Colors.transparent,
              ),
              childWhenDragging:
                  SizedBox.shrink(), //Hide the dock item when dragging.

              data: i,
              onDragCompleted: () {
                setState(() {
                  _draggedIndex = null; // Reset the dragged index.
                });
              },
              onDragStarted: () => setState(() {
                _draggedIndex = i; // Set the dragged index.
                _hoveredIndex = null; // Reset the hovered index.
              }),
              onDraggableCanceled: (_, __) => setState(() {
                _draggedIndex = null; // Reset the dragged index.
                _hoveredIndex = null; // Reset the hovered index.
              }),
            );
          })),
    );
  }

/**
 * Builds a dock item at the given index.
 * @param i The index of the item to build.
 * @return The built dock item.
 */
  Widget _buildDockItem(int i) {
    return DragTarget<int>(
        onAccept: (int index) {
          setState(() {
            final item =
                _items.removeAt(index); // Remove the item from the old index.
            _items.insert(i, item); // Insert the item at the new index.
          });
        },
        onMove: (details) {
          setState(() {
            _hoveredIndex = i; // Set the hovered index.
          });
        },
        onWillAccept: (fromIndex) =>
            fromIndex != i, // Prevent the item from being dropped on itself.
        onLeave: (details) {
          setState(() {
            _hoveredIndex = null; // Reset the hovered index.
          });
        },
        builder: (context, candidateData, rejectedData) {
          final con = Container(
            key: key,
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.add, color: Colors.transparent),
            color: Colors.transparent,
          );
          log(_hoveredIndex.toString());
          if (_draggedIndex == i) {
            return const SizedBox.shrink(); // Hide the dock item when dragging.
          }
          if (_hoveredIndex == i && _hoveredIndex != null) {
            _items.contains(con as T)
                ? _items.removeAt(i)
                : _items.insert(
                    _hoveredIndex!, con as T); // Reset the hovered index.
            return widget.builder(_items[i]);
          } else {
            return widget.builder(_items[i]);
          }
        });
  }
}
