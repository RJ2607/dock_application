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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Dock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) => Container(
              width: 48,
              height: 48,
              child: Icon(e, color: Colors.white),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items] with drag and drop functionality.
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

/// State of the [Dock] used to manipulate and reorder the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late List<T> _items = widget.items.toList();

  /// Currently dragged item.
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          return LongPressDraggable<int>(
            data: index,
            axis: Axis.horizontal,
            feedback: Material(
              color: Colors.transparent,
              child: widget.builder(_items[index]),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildDockItem(index),
            ),
            onDragStarted: () => setState(() {
              _draggingIndex = index;
            }),
            onDraggableCanceled: (_, __) => setState(() {
              _draggingIndex = null;
            }),
            onDragCompleted: () => setState(() {
              _draggingIndex = null;
            }),
            child: _buildDockItem(index),
          );
        }),
      ),
    );
  }

  /// Builds an individual dock item wrapped with [DragTarget] for receiving reorderable item.
  Widget _buildDockItem(int index) {
    return DragTarget<int>(
      onAccept: (fromIndex) {
        setState(() {
          final item = _items.removeAt(fromIndex);
          _items.insert(index, item);
        });
      },
      onWillAccept: (fromIndex) => fromIndex != index,
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          constraints: const BoxConstraints(minWidth: 48),
          height: 48,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.primaries[index % Colors.primaries.length],
          ),
          child: Center(child: widget.builder(_items[index])),
        );
      },
    );
  }
}
