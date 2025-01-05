import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matchday/pages/working_on/drag_drop_file/my_dragable_widget.dart';
import 'package:matchday/pages/working_on/drag_drop_file/my_drop_region.dart';
import 'package:matchday/pages/working_on/drag_drop_file/types.dart';

class SplitPanels extends StatefulWidget {
  const SplitPanels({
    super.key,
    this.columns = 9,
    this.itemSpacing = 10,
  });

  final int columns;
  final double itemSpacing;

  @override
  State<SplitPanels> createState() => _SplitPanelsState();
}

class _SplitPanelsState extends State<SplitPanels> {
  late List<String?> upper;
  final List<String> lower = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11'
  ];

  final int rows = 7;
  final int columns = 7;
  String selectedFormation = '4-4-2';

  final Map<String, List<int>> formations = {
    '4-4-2': [10, 12, 22, 28, 31, 33, 43, 45, 47, 49, 60]
        .map((num) => num - 1)
        .toList(),
    '4-3-3': [11, 16, 20, 30, 34, 39, 43, 45, 47, 49, 60]
        .map((num) => num - 1)
        .toList(),
    '3-5-2': [10, 12, 22, 28, 31, 33, 39, 51, 53, 55, 60]
        .map((num) => num - 1)
        .toList(),
  };

  PanelLocation? dragStart;
  PanelLocation? dropPreview;
  String? hoveringData;

  @override
  void initState() {
    super.initState();
    // Initialize upper with null values (empty grid)
    upper = List<String?>.filled(widget.columns * rows, null);
  }

  void onDragStart(PanelLocation start) {
    final data = switch (start.$2) {
      Panel.lower => lower[start.$1],
      Panel.upper => upper[start.$1],
    };
    setState(() {
      dragStart = start;
      hoveringData = data;
    });
  }

  void updateDropPreview(PanelLocation update) =>
      setState(() => dropPreview = update);

  void drop() {
    assert(dropPreview != null, 'Can only drop over a known location');
    assert(hoveringData != null, 'Can only drop when data is being dragged');
    setState(() {
      if (dragStart != null) {
        // Remove item from its original location
        if (dragStart!.$2 == Panel.upper) {
          upper[dragStart!.$1] = null; // Clear the slot in upper
        } else {
          lower.removeAt(dragStart!.$1); // Remove from lower
        }
      }

      // Place the item at the drop location if it's empty and valid
      if (dropPreview!.$2 == Panel.upper &&
          upper[dropPreview!.$1] == null &&
          formations[selectedFormation]!.contains(dropPreview!.$1)) {
        upper[dropPreview!.$1] = hoveringData!;
      } else if (dropPreview!.$2 == Panel.lower) {
        lower.insert(min(dropPreview!.$1, lower.length), hoveringData!);
      }

      // Reset dragging state
      dragStart = null;
      dropPreview = null;
      hoveringData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutters = widget.columns + 1;
        final spaceForColumns =
            constraints.maxWidth - (widget.itemSpacing * gutters);
        final columnWidth = spaceForColumns / widget.columns;
        final itemSize = Size(columnWidth, columnWidth);

        // Get the list of visible indices based on the selected formation
        final visibleIndices = formations[selectedFormation]!;

        return Stack(
          children: <Widget>[
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: DropdownButton<String>(
                value: selectedFormation,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedFormation = value);
                  }
                },
                items: formations.keys
                    .map((formation) => DropdownMenuItem(
                          value: formation,
                          child: Text(formation),
                        ))
                    .toList(),
              ),
            ),
            // Upper Panel with drop slots
            Positioned(
              height: constraints.maxHeight * 0.8,
              width: constraints.maxWidth,
              top: 50,
              child: MyDropRegion(
                updateDropPreview: updateDropPreview,
                onDrop: drop,
                columns: widget.columns,
                childSize: itemSize,
                panel: Panel.upper,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns, // Set the number of columns
                    mainAxisSpacing: widget.itemSpacing,
                    crossAxisSpacing: widget.itemSpacing,
                  ),
                  itemCount: upper.length,
                  itemBuilder: (context, index) {
                    // Skip rendering for indices not in the visible list
                    if (!visibleIndices.contains(index + 1)) {
                      return const SizedBox.shrink();
                    }

                    final item = upper[index];
                    return DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: item == null
                                    ? Colors.grey.shade200
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.1)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item ?? '', // Display the item if present
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Text(
                                '${index + 1}', // Display the grid number
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      onWillAccept: (data) =>
                          item == null, // Accept drop only if cell is empty
                      onAccept: (data) {
                        setState(() {
                          upper[index] = data; // Place the item
                          lower.remove(data); // Remove item from lower panel
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            // Separator line
            Positioned(
              height: 4,
              width: constraints.maxWidth,
              top: constraints.maxHeight * 0.78,
              child: const ColoredBox(
                color: Colors.black,
              ),
            ),
            // Lower Panel
            Positioned(
              height: constraints.maxHeight * 0.2,
              width: constraints.maxWidth,
              bottom: 0,
              child: MyDropRegion(
                updateDropPreview: updateDropPreview,
                onDrop: drop,
                columns: widget.columns,
                childSize: itemSize,
                panel: Panel.lower,
                child: ItemPanel(
                  crossAxisCount: widget.columns,
                  dragStart: dragStart?.$2 == Panel.lower ? dragStart : null,
                  items: lower,
                  onDragStart: onDragStart,
                  panel: Panel.lower,
                  spacing: widget.itemSpacing,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ItemPanel extends StatelessWidget {
  const ItemPanel(
      {super.key,
      required this.crossAxisCount,
      required this.dragStart,
      required this.items,
      required this.onDragStart,
      required this.panel,
      required this.spacing});

  final int crossAxisCount;
  final PanelLocation? dragStart;
  final List<String> items;
  final double spacing;

  final Function(PanelLocation) onDragStart;
  final Panel panel;

  @override
  Widget build(BuildContext context) {
    PanelLocation? dragStartCopy;
    if (dragStart != null) {
      dragStartCopy = dragStart!.copyWith();
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      padding: const EdgeInsets.all(1),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: items.asMap().entries.map<Widget>(
        (MapEntry<int, String> entry) {
          Color textColor =
              entry.key == dragStartCopy?.$1 ? Colors.grey : Colors.white;
          Widget child = Center(
              child: Text(
            entry.value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: textColor),
          ));

          if (entry.key == dragStartCopy?.$1) {
            child = Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: child,
            );
          } else {
            child = Container(
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: child,
            );
          }
          return Draggable(
            feedback: child,
            child: MyDragableWidget(
              data: entry.value,
              onDragStart: () => onDragStart((entry.key, panel)),
              child: child,
            ),
          );
        },
      ).toList(),
    );
  }
}
