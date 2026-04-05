import 'package:flutter/material.dart';

class LabeledValueRow extends StatelessWidget {
  const LabeledValueRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 84,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.labelStyle = const TextStyle(
      color: Colors.white54,
      fontWeight: FontWeight.w500,
    ),
    this.valueStyle = const TextStyle(color: Colors.white),
    this.hideWhenEmpty = true,
  });

  final String label;
  final String? value;
  final double labelWidth;
  final EdgeInsetsGeometry padding;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final bool hideWhenEmpty;

  @override
  Widget build(BuildContext context) {
    final resolvedValue = value;
    if (hideWhenEmpty &&
        (resolvedValue == null || resolvedValue.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, style: labelStyle),
          ),
          Expanded(
            child: Text(resolvedValue ?? '', style: valueStyle),
          ),
        ],
      ),
    );
  }
}
