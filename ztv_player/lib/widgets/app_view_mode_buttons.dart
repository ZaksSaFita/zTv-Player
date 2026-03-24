import 'package:flutter/material.dart';
import 'package:ztv_player/helpers/sort.dart';

class AppViewModeButtons extends StatelessWidget {
  const AppViewModeButtons({
    super.key,
    required this.columns,
    required this.iconColor,
    required this.activeColor,
    required this.onListSelected,
    required this.onGridSelected,
  });

  final int columns;
  final Color iconColor;
  final Color activeColor;
  final VoidCallback onListSelected;
  final VoidCallback onGridSelected;

  @override
  Widget build(BuildContext context) {
    final isListSelected = columns == 1;
    final gridIcon = AppView.iconFor(columns == 1 ? 2 : columns);
    final isGridSelected = columns > 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'List view',
          onPressed: onListSelected,
          icon: const Icon(Icons.view_agenda_outlined),
          color: isListSelected ? activeColor : iconColor,
        ),
        IconButton(
          tooltip: columns == 2 ? 'Grid 2x2' : 'Grid 3x3',
          onPressed: onGridSelected,
          icon: Icon(gridIcon),
          color: isGridSelected ? activeColor : iconColor,
        ),
      ],
    );
  }
}
