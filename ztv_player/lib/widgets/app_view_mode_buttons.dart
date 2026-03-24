import 'package:flutter/material.dart';
import 'package:ztv_player/helpers/sort.dart';

class AppViewModeButtons extends StatelessWidget {
  const AppViewModeButtons({
    super.key,
    required this.columns,
    required this.iconColor,
    required this.activeColor,
    required this.onPressed,
  });

  final int columns;
  final Color iconColor;
  final Color activeColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tooltip = switch (columns) {
      1 => 'List view',
      2 => 'Grid 2x2',
      _ => 'Grid 3x3',
    };

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(AppView.iconFor(columns)),
      color: columns == 1 ? iconColor : activeColor,
    );
  }
}
