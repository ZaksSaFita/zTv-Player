import 'package:flutter/material.dart';
import 'package:ztv_player/helpers/sort.dart';

class AppSortButton extends StatelessWidget {
  const AppSortButton({
    super.key,
    required this.value,
    required this.iconColor,
    required this.onSelected,
  });

  final SortType value;
  final Color iconColor;
  final ValueChanged<SortType> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortType>(
      tooltip: 'Sort',
      initialValue: value,
      onSelected: onSelected,
      icon: Icon(AppSort.iconFor(value), color: iconColor),
      itemBuilder: (context) => SortType.values
          .map(
            (option) => PopupMenuItem<SortType>(
              value: option,
              enabled: option != SortType.custome,
              child: Row(
                children: [
                  Icon(
                    AppSort.iconFor(option),
                    size: 18,
                    color: option == SortType.custome
                        ? Colors.white38
                        : option == value
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option == SortType.custome
                          ? '${AppSort.labelFor(option)} (Premium)'
                          : AppSort.labelFor(option),
                      style: TextStyle(
                        color: option == SortType.custome
                            ? Colors.white38
                            : null,
                        fontWeight: option == value
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (option == value && option != SortType.custome)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
