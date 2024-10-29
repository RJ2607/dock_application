import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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
                    child: Center(child: Icon(e, color: Colors.white)),
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

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();
  bool _isDragging = false;
  Widget? _draggedItem;
  int? _draggedIndex;
  int _hoverIndex = -1; // Initialize to -1 to avoid null checks.

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black12,
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length + 1, (i) {
            if (_hoverIndex == i) {
              return const SizedBox(
                width: 60,
                height: 48,
              );
            }
            final adjustedIndex =
                i > _hoverIndex && _hoverIndex != -1 ? i - 1 : i;
            if (adjustedIndex >= _items.length)
              return const SizedBox.shrink(); // Avoid out-of-range

            return _buildDockItem(adjustedIndex);
          }),
        ),
      ),
    );
  }

  Widget _buildDockItem(int i) {
    return DragTarget<int>(
      onAccept: (int index) {
        setState(() {
          _isDragging = false;
          final item = _items.removeAt(index);
          _items.insert(i, item);
          _hoverIndex = -1;
        });
      },
      onWillAccept: (fromIndex) {
        setState(() {
          if (fromIndex != i) _hoverIndex = i;
        });
        return fromIndex != i;
      },
      onLeave: (index) {
        setState(() {
          if (index != null && _isDragging == false) {
            _isDragging = true;

            _draggedItem = _items.removeAt(index);
          }
          _hoverIndex = -1;
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
          onDragStarted: () => setState(() => _draggedIndex = i),
          onDraggableCanceled: (_, __) => setState(() {
            _draggedIndex = null;
            _hoverIndex = -1;
          }),
          onDragCompleted: () => setState(() {
            _draggedIndex = null;
            _hoverIndex = -1;
          }),
          child: widget.builder(_items[i]),
        );
      },
    );
  }
}
